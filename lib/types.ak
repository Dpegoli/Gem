use aiken/crypto.{ScriptHash, VerificationKeyHash}
use cardano/address.{Credential}
use cardano/assets.{Lovelace}
use cardano/transaction.{OutputReference}

//use shared.{AcceptJob, CancelJob, CompleteJob, DisputeJob}

pub type Action =
  Int

pub type JobAction {
  AcceptJob
  CompleteJob
  CancelJob
  DisputeJob
}

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
  pay: Lovelace,
  // ✅ Changed from Int to Lovelace
  escrow: Lovelace,
  // ✅ Changed from Int to Lovelace
  utxo_ref: Option<OutputReference>,
  state: JobState,
  dispute: Bool,
  start_time: Int,
  end_time: Int,
  resumeEvidence: Option<ByteArray>,
  withdrawEscrow: Option<Lovelace>,
}

// ✅ Changed from Int to Lovelace

/// Represents the redeemer for job operations
pub type JobRedeemer {
  action: Int,
  reason: VerificationKeyHash,
  verifyresume: ByteArray,
  depositEscrow: Option<Lovelace>,
  // ✅ Changed from Int to Lovelace
  withdrawEscrow: Option<Lovelace>,
  // ✅ Changed from Int to Lovelace
  quitJob: Bool,
  // Allows jobber to exit while ensuring partial payment (if applicable).
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

pub type WAddress {
  payment_credential: Credential,
  stake_credential: Option<Credential>,
}

pub type PaymentKeyHash =
  VerificationKeyHash

// ✅ Alias for clarity

pub type StakeKeyHash =
  VerificationKeyHash
// ✅ Alias for clarity
