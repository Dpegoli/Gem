use aiken/interval.{Finite, Interval, IntervalBound}
use cardano/transaction.{Transaction}
use shared.{validate_escrow}
use types.{JobDatum, Open}

test test_validate_escrow() {
  let valid_datum =
    JobDatum {
      job_id: 1,
      employer: #"a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0",
      jobber: None,
      pay: 5_000_000,
      escrow: 5_000_000,
      utxo_ref: None,
      state: Open,
      dispute: False,
      start_time: 100_000,
      end_time: 200_000,
      resumeEvidence: None,
      withdrawEscrow: None,
    }

  let invalid_datum =
    JobDatum {
      job_id: 2,
      employer: #"b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f1",
      jobber: None,
      pay: 5_000_000,
      escrow: 3_000_000,
      utxo_ref: None,
      state: Open,
      dispute: False,
      start_time: 100_000,
      end_time: 200_000,
      resumeEvidence: None,
      withdrawEscrow: None,
    }

  let signatories =
    [#"a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0"]

  let validity_range =
    Interval {
      lower_bound: IntervalBound {
        bound_type: Finite(100_000),
        is_inclusive: True,
      },
      upper_bound: IntervalBound {
        bound_type: Finite(200_000),
        is_inclusive: True,
      },
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      extra_signatories: signatories,
      validity_range: validity_range,
    }

  expect validate_escrow(valid_datum, tx) == True
  expect validate_escrow(invalid_datum, tx) == False
}
