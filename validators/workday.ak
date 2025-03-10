use aiken/crypto.{VerificationKeyHash}
use aiken/interval.{Finite, IntervalBound}
use cardano/transaction.{OutputReference, Transaction, ValidityRange}
use shared.{accept_job, cancel_job, complete_job, dispute_job}
use types.{JobDatum, JobRedeemer}

validator workday_validator {
  spend(
    datum: Option<JobDatum>,
    redeemer: JobRedeemer,
    _utxo: OutputReference,
    transaction: Transaction,
  ) {
    expect Some(datum) = datum
    let end_time =
      when transaction.validity_range.upper_bound.bound_type is {
        Finite(tx_time) -> tx_time
        _ -> fail @"Invalid upper bound"
      }

    when redeemer.action is {
      0 ->
        accept_job(
          datum,
          redeemer,
          transaction.extra_signatories,
          transaction,
          transaction.validity_range,
        )
      1 ->
        cancel_job(datum, redeemer, transaction.extra_signatories, transaction)
      2 ->
        complete_job(
          datum,
          redeemer,
          transaction.extra_signatories,
          transaction.validity_range,
        )
      3 ->
        dispute_job(
          datum,
          redeemer,
          transaction.extra_signatories,
          transaction.validity_range,
        )
      _ -> fail @"Invalid redeemer action"
    }
  }

  else(_) {
    fail @"Only spend operations are supported"
  }
}
