use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{Finite, IntervalBound}
use cardano/transaction.{Transaction, ValidityRange}
use types.{Accepted, Completed, Disputed, JobDatum, JobRedeemer, Open}
use utils.{validate_slots}

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

/// Function to validate that a job is open
pub fn accept_job(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
  tx: Transaction,
  validity_range: ValidityRange,
) -> Bool {
  and {
    must_be_signed_by(signatories, redeemer.reason),
    datum.state == Open,
    validate_slots(tx.validity_range, datum.start_time, datum.end_time),
  }
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
  signatories: List<VerificationKeyHash>,
  validity_range: ValidityRange,
) -> Bool {
  and {
    datum.state == Accepted,
    // Ensure the job is in the Accepted state
    when datum.jobber is {
      Some(jobber) -> jobber == redeemer.reason
      // Validate the jobber matches the redeemer
      None -> False
    },
    // If no jobber is assigned, the completion is invalid
    must_be_signed_by(signatories, redeemer.reason),
    // Validate that the jobber signed the transaction
    validate_working_day(validity_range, datum.start_time, datum.end_time),
  }
  // Ensure the transaction is within working hours
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
  // ✅ Change ValidityRange to Int
  and {
    datum.state == Accepted || datum.state == Disputed,
    // ✅ Job must be active or already disputed
    must_be_signed_by(signatories, redeemer.reason),
    // ✅ Jobber or employer must trigger timeout
    datum.end_time + 10_000 < current_time,
    // ✅ Job has exceeded max allowed time
    datum.withdrawEscrow != None,
  }
  // ✅ Ensure escrow is available for payout
}

/// Function to cancel a job
pub fn cancel_job(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
  tx: Transaction,
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
  // ✅ Removed `redeemer`
  and {
    datum.state == Open,
    // Job must be open
    datum.escrow >= datum.pay,
    // ✅ Ensure escrow matches or exceeds pay
    must_be_signed_by(transaction.extra_signatories, datum.employer),
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
  // ✅ Ensure there is escrow to withdraw
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
    // ❌ Can't quit if no jobber assigned
    datum.start_time + 2_000 < current_time,
    // ✅ Ensure jobber worked a minimum duration
    datum.escrow > 0,
  }
  // ✅ Escrow must be available for partial refund
}
