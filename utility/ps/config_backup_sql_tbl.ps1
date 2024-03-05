# Read data from CSV "tableName", "schemaName", "indexType"
$csvData = Import-Csv -Path "C:\Utility\PowerShell\ConfigTableDetails.csv"

# generate current date YYYYMMDD in $dateToday
$dateToday = Get-Date -Format "yyyyMMdd"

# To access the data, you can iterate over $csvData
foreach ($row in $csvData) {
    $tableName = $row.tableName
    $schemaName = $row.schemaName
    $indexType = $row.indexType

    # Print or process the data
    # Write-Output "Table: $tableName, Schema: $schemaName, IndexType: $indexType"

    $sqlCreateTbl =""

    $sqlCreateTbl = "/* ********Table: $tableName, Schema: $schemaName, IndexType: $indexType ****** */`n`n"

    if ($indexType -eq 'CLUSTERED')
    {
        $sqlCreateTbl = $sqlCreateTbl + "CREATE TABLE " + $schemaName + "." + $tableName + "_CDR1CI_NEW `nWITH `n( `n    DISTRIBUTION = HASH (Id), `n    CLUSTERED INDEX (Id) `n) `nAS `nSELECT TOP 0 * FROM " + $schemaName + "." + $tableName + "; `n" +
        "RENAME OBJECT " + $schemaName + "." + $tableName + " TO " + $schemaName + "." + $tableName + "_" + $dateToday + "; `n" +
        "RENAME OBJECT " + $schemaName + "." + $tableName + "_CDR1CI_NEW TO " + $schemaName + "." + $tableName + "; `n"
    }
    elseif ($indexType -eq 'CLUSTERED COLUMNSTORE')
    {
        $sqlCreateTbl = $sqlCreateTbl + "SELECT TOP 0 * INTO " + $schemaName + "." + $tableName + "_CDR1CCI_NEW FROM " + $schemaName + "." + $tableName + "; `n" +
        "RENAME OBJECT " + $schemaName + "." + $tableName + " TO " + $schemaName + "." + $tableName + "_" + $dateToday + "; `n" +
        "RENAME OBJECT " + $schemaName + "." + $tableName + "_CDR1CCI_NEW TO " + $schemaName + "." + $tableName + "; `n"
    } elseif ($indexType -eq 'HEAP')
    {
        $sqlCreateTbl = $sqlCreateTbl + "CREATE TABLE " + $schemaName + "." + $tableName + "_CDR1HEAP_NEW `nWITH `n( `n    DISTRIBUTION = ROUND_ROBIN, `n    HEAP `n) `nAS `nSELECT TOP 0 * FROM " + $schemaName + "." + $tableName + "; `n" +
        "RENAME OBJECT " + $schemaName + "." + $tableName + " TO " + $schemaName + "." + $tableName + "_" + $dateToday + "; `n" +
        "RENAME OBJECT " + $schemaName + "." + $tableName + "_CDR1HEAP_NEW TO " + $schemaName + "." + $tableName + "; `n"
        <# Action when this condition is true #>
    }

    Write-Output $sqlCreateTbl
}

