;; REC Registry Contract

(define-map recs
  { rec-id: uint }
  {
    producer: principal,
    energy-amount: uint,
    production-date: uint,
    expiration-date: uint,
    status: (string-ascii 20)
  }
)

(define-data-var rec-nonce uint u0)

(define-public (issue-rec
  (energy-amount uint)
  (production-date uint)
  (expiration-date uint))
  (let
    ((new-id (+ (var-get rec-nonce) u1)))
    (map-set recs
      { rec-id: new-id }
      {
        producer: tx-sender,
        energy-amount: energy-amount,
        production-date: production-date,
        expiration-date: expiration-date,
        status: "active"
      }
    )
    (var-set rec-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-rec (rec-id uint))
  (map-get? recs { rec-id: rec-id })
)

(define-public (update-rec-status (rec-id uint) (new-status (string-ascii 20)))
  (let
    ((rec (unwrap! (map-get? recs { rec-id: rec-id }) (err u404))))
    (asserts! (is-eq tx-sender (get producer rec)) (err u403))
    (map-set recs
      { rec-id: rec-id }
      (merge rec { status: new-status })
    )
    (ok true)
  )
)

(define-read-only (get-last-rec-id)
  (var-get rec-nonce)
)

