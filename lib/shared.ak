use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{Finite, Interval, IntervalBound}
use cardano/transaction.{Transaction, ValidityRange}
use types.{Accepted, Completed, Disputed, JobDatum, JobRedeemer, Open}

// Import all constructors of JobState

/// Function to validate that a job transaction is signed by a specific user
pub fn must_be_signed_by(
  signatories: List<VerificationKeyHash>,
  required_signer: VerificationKeyHash,
) -> Bool {
  list.has(signatories, required_signer)
}

/// Function to validate the working day timeframe
pub fn validate_working_day(
  validity_range: ValidityRange,
  start_time: Int,
  end_time: Int,
) -> Bool {
  when validity_range.lower_bound.bound_type is {
    Finite(tx_time) -> tx_time >= start_time && tx_time <= end_time
    _ -> False
  }
}

pub fn accept_job(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<ByteArray>,
  tx: Transaction,
) -> Bool {
  // Ensure job is still Open
  expect Open = datum.state

  // Ensure jobber provides a valid resume
  let resume_valid =
    when datum.resumeEvidence is {
      Some(expected_resume) -> redeemer.verifyresume == expected_resume
      None -> False
    }

  // Ensure jobber exists and has signed
  let jobber_signed =
    when datum.jobber is {
      Some(jobber) -> list.has(signatories, jobber)
      None -> False
    }

  // Ensure employer has signed to approve the jobber
  let employer_signed = list.has(signatories, datum.employer)

  // Ensure correct escrow deposit
  let escrow_valid =
    when redeemer.depositEscrow is {
      Some(amount) -> amount == datum.escrow
      None -> False
    }

  // Verify transaction validity (valid range for acceptance)
  let within_validity = interval.contains(tx.validity_range, datum.start_time)

  // Ensure all conditions are met
  and {
    resume_valid,
    // Jobber must provide a valid resume
    jobber_signed,
    // Jobber must sign
    employer_signed,
    // Employer must approve the jobber
    escrow_valid,
    // Jobber must deposit escrow
    within_validity,
  }
  // Transaction must be within the correct validity range
}

/// Function to abort the job
pub fn abort(datum: JobDatum, signatories: List<VerificationKeyHash>) -> Bool {
  and {
    datum.state == Open,
    must_be_signed_by(signatories, datum.employer),
    when datum.jobber is {
      Some(jobber) -> must_be_signed_by(signatories, jobber)
      None -> True
    },
  }
}

/// Function to close a job
pub fn close_job(
  datum: JobDatum,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  and {
    datum.state == Completed,
    // Ensure the job is marked as completed
    must_be_signed_by(signatories, datum.employer),
    // Employer's signature is required
    when datum.jobber is {
      Some(jobber) -> must_be_signed_by(signatories, jobber)
      // Jobber's signature is required if a jobber exists
      None -> True
    },
  }
  // If no jobber is assigned, only the employer's signature is required
}

/// Function to complete a job
pub fn complete_job(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<ByteArray>,
  validity_range: Interval<Int>,
) -> Bool {
  // Ensure job is still Open
  expect Open = datum.state

  // Ensure jobber exists and has signed
  let jobber_signed =
    when datum.jobber is {
      Some(jobber) -> list.has(signatories, jobber)
      None -> False
    }

  // Ensure employer has signed to approve completion
  let employer_signed = list.has(signatories, datum.employer)

  // Ensure completion is within job timeframe
  let within_time = interval.is_entirely_before(validity_range, datum.end_time)

  // Validate escrow release (jobber gets refund if job is completed)
  let escrow_valid =
    when redeemer.withdrawEscrow is {
      Some(amount) -> amount == datum.escrow
      None -> False
    }

  // If escrow is missing, fail validation
  // Ensure all conditions are met
  and {
    jobber_signed,
    employer_signed,
    within_time,
    escrow_valid,
  }
}

/// Function to dispute a job
pub fn dispute_job(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
  validity_range: ValidityRange,
) -> Bool {
  and {
    !datum.dispute,
    // Ensure the job is not already disputed
    must_be_signed_by(signatories, redeemer.reason),
    // Validate that the initiator of the dispute signed the transaction
    validate_working_day(validity_range, datum.start_time, datum.end_time),
  }
  // Ensure the transaction is within working hours
}

/// Function to resolve a job dispute
pub fn resolve_dispute(
  datum: JobDatum,
  _redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  and {
    datum.state == Disputed,
    // Ensure the job is in the Disputed state
    must_be_signed_by(signatories, datum.employer),
    // Validate the employer signed the transaction
    when datum.jobber is {
      Some(jobber) -> must_be_signed_by(signatories, jobber)
      // Validate the jobber signed the transaction if assigned
      None -> False
    },
  }
  // If no jobber is assigned, resolution is invalid
}

/// Function to handle job disputes due to timeout (e.g., employer non-payment)
pub fn timeout_dispute(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
  current_time: Int,
) -> Bool {
  and {
    datum.state == Accepted || datum.state == Disputed,
    // Job must be active or already disputed
    must_be_signed_by(signatories, redeemer.reason),
    // Jobber or employer must trigger timeout
    datum.end_time + 10_000 < current_time,
    // Job has exceeded max allowed time
    datum.withdrawEscrow != None,
  }
  // Ensure escrow is available for payout
}

/// Function to cancel a job
pub fn cancel_job(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
  _tx: Transaction,
) -> Bool {
  if redeemer.reason == datum.employer {
    // Cancellation initiated by the employer
    and {
      datum.state == Open || datum.state == Accepted,
      // Job must be in Open or Accepted state
      must_be_signed_by(signatories, datum.employer),
    }
  } else {
    // Ensure employer's signature is present
    // Cancellation initiated by the jobber
    when datum.jobber is {
      Some(jobber) -> and {
          redeemer.reason == jobber,
          // Ensure the redeemer matches the assigned jobber
          datum.state == Accepted || datum.state == Open,
          // Job must be in Open or Accepted state
          must_be_signed_by(signatories, jobber),
        }
      // Ensure jobber's signature is present
      None -> False
    }
  }
  // If no jobber is assigned, the jobber cannot cancel
}

/// Ensures escrow funds are locked before accepting a job
pub fn validate_escrow(datum: JobDatum, transaction: Transaction) -> Bool {
  when datum.state is {
    Open -> and {
        datum.escrow >= datum.pay,
        must_be_signed_by(transaction.extra_signatories, datum.employer),
      }
    Accepted -> False
    Completed -> False
    Disputed -> False
  }
}

/// Function to handle escrow withdrawal
pub fn withdraw_escrow(
  datum: JobDatum,
  _redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  and {
    datum.state == Open || datum.state == Accepted,
    must_be_signed_by(signatories, datum.employer),
    datum.escrow > 0,
  }
  // Ensure there is escrow to withdraw
}

pub fn quit_job(
  datum: JobDatum,
  _redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
  current_time: Int,
) -> Bool {
  and {
    datum.state == Accepted,
    // ✅ Only quit if job is active
    when datum.jobber is {
      Some(jobber) -> must_be_signed_by(signatories, jobber)
      None -> False
    },
    // Can't quit if no jobber assigned
    datum.start_time + 2_000 < current_time,
    // Ensure jobber worked a minimum duration
    datum.escrow > 0,
  }
  // Escrow must be available for partial refund
}

// `extract_time` function
pub fn extract_time(bound: IntervalBound<Int>) -> Int {
  when bound.bound_type is {
    Finite(time) -> time
    _ -> fail @"Invalid transaction time"
  }
}
