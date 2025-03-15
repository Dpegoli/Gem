////trying new validator with schedule hours and escrow 

use aiken/collection/list
use aiken/interval.{Interval}
use cardano/transaction.{OutputReference, Transaction}
use shared.{
  accept_job, cancel_job, complete_job, dispute_job, extract_time,
  validate_escrow,
}
use types.{JobDatum, JobRedeemer}

//use utils.{validate_slots}

// validator workday_validator {
//   spend(
//     datum: Option<JobDatum>,
//     redeemer: JobRedeemer,
//     _utxo: OutputReference,
//     transaction: Transaction,
//   ) {
//     // Extract datum safely
//     let job_datum =
//       when datum is {
//         Some(d) -> d
//         None -> fail @"Missing datum"
//       }

//     // Extract transaction validity interval
//     let valid_range = transaction.validity_range

//     // Extract transaction execution time
//     let tx_time = extract_time(valid_range.upper_bound)

//     // Define work shifts
//     let morning_shift = interval.between(9 * 3600, 12 * 3600)
//     // 9 AM - 12 PM
//     let evening_shift = interval.between(14 * 3600, 18 * 3600)

//     // 2 PM - 6 PM
//     // Merge both shifts into a single valid range
//     let allowed_hours = interval.hull(morning_shift, evening_shift)

//     // Assign conditions to variables first
//     let is_within_hours = interval.contains(allowed_hours, tx_time)
//     let is_escrow_valid = validate_escrow(job_datum, transaction)

//     //New approach: Use `when` for validation logic
//     when is_within_hours && is_escrow_valid is {
//       True ->
//         // Handle redeemer actions
//         when redeemer.action is {
//           0 ->
//             accept_job(
//               job_datum,
//               redeemer,
//               transaction.extra_signatories,
//               transaction,
//               transaction.validity_range,
//             )
//           1 ->
//             cancel_job(
//               job_datum,
//               redeemer,
//               transaction.extra_signatories,
//               transaction,
//             )
//           2 ->
//             complete_job(
//               job_datum,
//               redeemer,
//               transaction.extra_signatories,
//               transaction.validity_range,
//             )
//           3 ->
//             dispute_job(
//               job_datum,
//               redeemer,
//               transaction.extra_signatories,
//               transaction.validity_range,
//             )
//           _ -> fail @"Invalid redeemer action"
//         }
//       False -> fail @"Transaction is invalid: Time or Escrow issue"
//     }
//   }

//   else(_) {
//     fail @"Only spend operations are supported"
//   }
// }

fn prevent_double_spend(own_ref: OutputReference, tx: Transaction) -> Bool {
  let all_inputs: List<OutputReference> =
    list.map(tx.inputs, fn(i) { i.output_reference })
  let occurrences =
    list.length(list.filter(all_inputs, fn(ref) { ref == own_ref }))
  occurrences == 1
}

validator workday_validator {
  spend(
    datum: Option<JobDatum>,
    redeemer: JobRedeemer,
    own_ref: OutputReference,
    // Added own_ref for double-spend check
    transaction: Transaction,
  ) {
    // Extract datum safely
    let job_datum =
      when datum is {
        Some(d) -> d
        None -> fail @"Missing datum"
      }

    // Prevent double spending
    expect prevent_double_spend(own_ref, transaction)

    // Extract transaction validity interval
    let valid_range = transaction.validity_range

    // Extract transaction execution time
    let tx_time = extract_time(valid_range.upper_bound)

    // Define work shifts
    let morning_shift = interval.between(9 * 3600, 12 * 3600)
    // 9 AM - 12 PM
    let evening_shift = interval.between(14 * 3600, 18 * 3600)

    // 2 PM - 6 PM
    // Merge both shifts into a single valid range
    let allowed_hours = interval.hull(morning_shift, evening_shift)

    // Assign conditions to variables first
    let is_within_hours = interval.contains(allowed_hours, tx_time)
    let is_escrow_valid = validate_escrow(job_datum, transaction)

    // Use `when` for validation logic
    when is_within_hours && is_escrow_valid is {
      True ->
        // Handle redeemer actions
        when redeemer.action is {
          0 ->
            accept_job(
              job_datum,
              redeemer,
              transaction.extra_signatories,
              transaction,
            )
          1 ->
            cancel_job(
              job_datum,
              redeemer,
              transaction.extra_signatories,
              transaction,
            )
          2 ->
            complete_job(
              job_datum,
              redeemer,
              transaction.extra_signatories,
              transaction.validity_range,
            )
          3 ->
            dispute_job(
              job_datum,
              redeemer,
              transaction.extra_signatories,
              transaction.validity_range,
            )
          _ -> fail @"Invalid redeemer action"
        }
      False -> fail @"Transaction is invalid: Time or Escrow issue"
    }
  }

  else(_) {
    fail @"Only spend operations are supported"
  }
}
