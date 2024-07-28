SELECT
  CASE
    WHEN p.BankName IN ('D', 'O', 'U') THEN t.IdentifierNumber
    WHEN p.TaxType = 'Income' THEN
      CASE
        WHEN EXISTS (SELECT 1 FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 0) THEN
          COALESCE(
            (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 0 AND OcdeIdentifiertype = 'MIC'),
            (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 0 AND OcdeIdentifiertype = 'PP'),
            (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 0 AND OcdeIdentifiertype = 'WIP')
          )
        ELSE
          (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 1)
      END
    WHEN p.TaxType = 'Property' THEN
      CASE
        WHEN EXISTS (SELECT 1 FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 1 AND OcdeIdentifiertype = 'Fin') THEN
          COALESCE(
            (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 1 AND OcdeIdentifiertype = 'MIC'),
            (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 1 AND OcdeIdentifiertype = 'PP')
          )
        WHEN EXISTS (SELECT 1 FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 1 AND OcdeIdentifiertype = 'UENO') THEN
          COALESCE(
            (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 1 AND OcdeIdentifiertype = 'UENC'),
            (SELECT IdentifierNumber FROM #tE WHERE #tEID = p.#tEID AND IsPrimary = 1 AND OcdeIdentifiertype = 'UENB')
          )
      END
  END AS SecondaryID
FROM
  PReport p
  INNER JOIN #tE t ON p.#tEID = t.#tEID
WHERE
  t.EntityIDType = '#N'
  OR t.EntityIDType <> '#N';
