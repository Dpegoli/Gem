use aiken/crypto.{VerificationKeyHash}
use shared.{must_be_signed_by}
use types.{JobDatum, JobRedeemer}

/// Function to verify resume authenticity
pub fn verify_resume(
  job_datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
) -> Bool {
  and {
    must_be_signed_by(signatories, job_datum.employer),
    // Ensure employer verifies resume
    when job_datum.resumeEvidence is {
      Some(evidence) -> evidence == redeemer.verifyresume
      None -> False
    },
  }
}
