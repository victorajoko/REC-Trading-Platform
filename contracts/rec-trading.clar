;; REC Trading Contract

(define-map rec-listings
  { listing-id: uint }
  {
    rec-id: uint,
    seller: principal,
    price: uint,
    status: (string-ascii 20)
  }
)

(define-data-var listing-nonce uint u0)

(define-public (create-listing (rec-id uint) (price uint))
  (let
    ((new-id (+ (var-get listing-nonce) u1))
     (rec (unwrap! (contract-call? .rec-registry get-rec rec-id) (err u404))))
    (asserts! (is-eq tx-sender (get producer rec)) (err u403))
    (asserts! (is-eq (get status rec) "active") (err u403))
    (map-set rec-listings
      { listing-id: new-id }
      {
        rec-id: rec-id,
        seller: tx-sender,
        price: price,
        status: "active"
      }
    )
    (var-set listing-nonce new-id)
    (ok new-id)
  )
)

(define-read-only (get-listing (listing-id uint))
  (map-get? rec-listings { listing-id: listing-id })
)

(define-public (buy-rec (listing-id uint))
  (let
    ((listing (unwrap! (map-get? rec-listings { listing-id: listing-id }) (err u404))))
    (asserts! (is-eq (get status listing) "active") (err u403))
    (try! (stx-transfer? (get price listing) tx-sender (get seller listing)))
    (try! (contract-call? .rec-registry update-rec-status (get rec-id listing) "transferred"))
    (map-set rec-listings
      { listing-id: listing-id }
      (merge listing { status: "sold" })
    )
    (ok true)
  )
)

(define-public (cancel-listing (listing-id uint))
  (let
    ((listing (unwrap! (map-get? rec-listings { listing-id: listing-id }) (err u404))))
    (asserts! (is-eq tx-sender (get seller listing)) (err u403))
    (asserts! (is-eq (get status listing) "active") (err u403))
    (map-set rec-listings
      { listing-id: listing-id }
      (merge listing { status: "cancelled" })
    )
    (ok true)
  )
)

(define-read-only (get-last-listing-id)
  (var-get listing-nonce)
)

