-- 002_connector_tokens.sql (delta: encrypted API tokens for connectors)
CREATE TABLE IF NOT EXISTS connector_tokens (
  connectorId    TEXT PRIMARY KEY,
  encVersion     INTEGER NOT NULL,
  encAlg         TEXT NOT NULL,
  encNonce       TEXT NOT NULL,
  encCiphertext  TEXT NOT NULL,
  createdAt      TEXT NOT NULL,
  updatedAt      TEXT NOT NULL,
  FOREIGN KEY (connectorId) REFERENCES connectors(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_connector_tokens_connectorId ON connector_tokens(connectorId);
