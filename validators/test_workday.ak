use aiken/interval.{Finite, Interval, IntervalBound}
use cardano/transaction.{Transaction}
use shared.{accept_job}
use types.{JobDatum, JobRedeemer, Open}

test test_accept_job() {
  let datum =
    JobDatum {
      job_id: 1,
      employer: #"a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0",
      jobber: None,
      pay: 5_000_000,
      escrow: 2_000_000,
      utxo_ref: None,
      state: Open,
      dispute: False,
      start_time: 100_000,
      end_time: 200_000,
      resumeEvidence: None,
      withdrawEscrow: None,
    }

  let redeemer =
    JobRedeemer {
      action: 0,
      reason: #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50",
      verifyresume: #"c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0",
      depositEscrow: Some(2_000_000),
      withdrawEscrow: None,
      quitJob: False,
      disputeTimeout: False,
    }

  let signatories =
    [#"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"]

  let validity_range =
    Interval {
      lower_bound: IntervalBound {
        bound_type: Finite(datum.start_time),
        is_inclusive: True,
      },
      upper_bound: IntervalBound {
        bound_type: Finite(datum.end_time),
        is_inclusive: True,
      },
    }

  let tx =
    Transaction {
      ..transaction.placeholder,
      extra_signatories: signatories,
      validity_range: validity_range,
    }

  // Ensure correct range
  expect accept_job(datum, redeemer, signatories, tx, validity_range) == True
}
