;; Collective Thought Consensus Mechanism Contract

(define-map thought-proposals
  { id: uint }
  {
    proposer: principal,
    thought-data: (string-utf8 256),
    status: (string-ascii 20),
    consensus-level: uint
  }
)

(define-map thought-votes
  { proposal-id: uint, voter: principal }
  {
    vote-weight: uint,
    resonance-level: uint
  }
)

(define-data-var next-proposal-id uint u0)

(define-public (propose-thought (thought-data (string-utf8 256)))
  (let
    ((new-id (var-get next-proposal-id)))
    (var-set next-proposal-id (+ new-id u1))
    (ok (map-set thought-proposals
      { id: new-id }
      {
        proposer: tx-sender,
        thought-data: thought-data,
        status: "proposed",
        consensus-level: u0
      }
    ))
  )
)

(define-public (vote-on-thought (proposal-id uint) (vote-weight uint) (resonance-level uint))
  (begin
    (map-set thought-votes
      { proposal-id: proposal-id, voter: tx-sender }
      {
        vote-weight: vote-weight,
        resonance-level: resonance-level
      }
    )
    (ok (update-consensus-level proposal-id))
  )
)

(define-public (finalize-thought (proposal-id uint))
  (match (map-get? thought-proposals { id: proposal-id })
    proposal
      (begin
        (asserts! (>= (get consensus-level proposal) u70) (err u403))
        (ok (map-set thought-proposals
          { id: proposal-id }
          (merge proposal { status: "accepted" })
        )))
    (err u404)
  )
)

(define-read-only (get-thought-proposal (proposal-id uint))
  (map-get? thought-proposals { id: proposal-id })
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? thought-votes { proposal-id: proposal-id, voter: voter })
)

(define-private (update-consensus-level (proposal-id uint))
  (match (map-get? thought-proposals { id: proposal-id })
    proposal
      (let
        ((new-level (calculate-consensus proposal-id)))
        (map-set thought-proposals
          { id: proposal-id }
          (merge proposal { consensus-level: new-level })
        ))
    false)
)

(define-private (calculate-consensus (proposal-id uint))
  ;; In a real implementation, this would aggregate all votes and calculate consensus
  ;; For simplicity, we'll just return a placeholder value
  u75
)

