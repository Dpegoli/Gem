use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{Finite, IntervalBound}
use cardano/transaction.{ValidityRange}
use types.{JobDatum, JobRedeemer, Open}

pub fn must_be_signed_by(
  signatories: List<VerificationKeyHash>,
  required_signer: VerificationKeyHash,
) -> Bool {
  list.has(signatories, required_signer)
}

pub fn validate_slots(
  validity_range: ValidityRange,
  start_time: Int,
  end_time: Int,
) -> Bool {
  when validity_range.lower_bound.bound_type is {
    Finite(tx_time) -> tx_time >= start_time && tx_time <= end_time
    _ -> False
  }
}

pub fn validate_workday(
  datum: JobDatum,
  redeemer: JobRedeemer,
  signatories: List<VerificationKeyHash>,
  validity_range: ValidityRange,
) -> Bool {
  must_be_signed_by(signatories, redeemer.reason) && datum.state == Open && validate_slots(
    validity_range,
    datum.start_time,
    datum.end_time,
  )
}
