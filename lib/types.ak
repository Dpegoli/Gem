use aiken/crypto.{ScriptHash, VerificationKeyHash}
use cardano/assets.{Lovelace, PolicyId}
use cardano/transaction.{OutputReference}

pub type JobState {
  Open
  Accepted
  Completed
  Disputed
}

/// Represents the data associated with a job
pub type JobDatum {
  job_id: Int,
  employer: VerificationKeyHash,
  jobber: Option<VerificationKeyHash>,
  pay: Int,
  escrow: Int,
  //Amount locked in escrow
  utxo_ref: Option<OutputReference>,
  state: JobState,
  dispute: Bool,
  start_time: Int,
  // Start time for the job
  end_time: Int,
  resumeEvidence: Option<ByteArray>,
  withdrawEscrow: Option<Int>,
}

/// Represents the redeemer for job operations
pub type JobRedeemer {
  action: Int,
  reason: VerificationKeyHash,
  verifyresume: ByteArray,
  depositEscrow: Option<Int>,
  withdrawEscrow: Option<Int>,
  quitJob: Bool,
  //  quitJob → Allows jobber to exit while ensuring partial payment (if applicable).
  disputeTimeout: Bool,
}

pub type PaymentCredential {
  VerificationKey(VerificationKeyHash)
  Script(ScriptHash)
}

/// Resume Verification Data
pub type ResumeDatum {
  resume_id: ByteArray,
  // Unique identifier for the resume
  verified_by: VerificationKeyHash,
  // Verifier who signed the resume
  timestamp: Int,
  // Timestamp of verification
  notes: ByteArray,
}

/// Resume Spend Actions
pub type ResumeAction {
  RUpdate { resume_id: ByteArray, timestamp: Int, new_notes: ByteArray }
  RInvalidate
}
