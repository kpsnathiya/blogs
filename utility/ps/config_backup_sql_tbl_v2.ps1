# Read data from CSV "tableName", "schemaName", "indexType"
$folderPath = "C:\Utility\PowerShell"

$csvData = Import-Csv -Path "$folderPath\configTableDetails.csv"

# generate current date YYYYMMDD in $dateToday
$dateToday = Get-Date -Format "yyyyMMdd"

# Generate unique domain name as list to loop through
$uniqueDomains = $csvData.domainName | Sort-Object -Unique

foreach ($domain in $uniqueDomains) {

    # Write-Host "DomainName: $domain"
    $configData = $csvData | Where-Object {$_.domainName -eq $domain} | Select-Object tableName, schemaName, indexType, domainName

    $domainCreateTbl =""

    foreach ($row in $configData) {
        $tableName = $row.tableName
        $schemaName = $row.schemaName
        $indexType = $row.indexType
        $domainName = $row.domainName

        # Write-Output "Domain: $domainName, Table: $tableName, Schema: $schemaName, IndexType: $indexType"
        $sqlCreateTbl =""
        $sqlCreateTbl = "`n/* ******** DomainName:$domainName, Table: $tableName, Schema: $schemaName, IndexType: $indexType ****** */`n`n"
    
        if ($indexType -eq 'CLUSTERED')
        {
            $sqlCreateTbl = $sqlCreateTbl + "CREATE TABLE " + $schemaName + "." + $tableName + "_CDR1CI_NEW `nWITH `n( `n    DISTRIBUTION = HASH (Id), `n    CLUSTERED INDEX (Id) `n) `nAS `nSELECT TOP 0 * FROM " + $schemaName + "." + $tableName + "; `n" +
            "`nRENAME OBJECT " + $schemaName + "." + $tableName + " TO " + $schemaName + "." + $tableName + "_" + $dateToday + "; `n" +
            "`nRENAME OBJECT " + $schemaName + "." + $tableName + "_CDR1CI_NEW TO " + $schemaName + "." + $tableName + "; `n"
        }
        elseif ($indexType -eq 'CLUSTERED COLUMNSTORE')
        {
            $sqlCreateTbl = $sqlCreateTbl + "SELECT TOP 0 * INTO " + $schemaName + "." + $tableName + "_CDR1CCI_NEW FROM " + $schemaName + "." + $tableName + "; `n" +
            "`nRENAME OBJECT " + $schemaName + "." + $tableName + " TO " + $schemaName + "." + $tableName + "_" + $dateToday + "; `n" +
            "`nRENAME OBJECT " + $schemaName + "." + $tableName + "_CDR1CCI_NEW TO " + $schemaName + "." + $tableName + "; `n"
        } elseif ($indexType -eq 'HEAP')
        {
            $sqlCreateTbl = $sqlCreateTbl + "CREATE TABLE " + $schemaName + "." + $tableName + "_CDR1HEAP_NEW `nWITH `n( `n    DISTRIBUTION = ROUND_ROBIN, `n    HEAP `n) `nAS `nSELECT TOP 0 * FROM " + $schemaName + "." + $tableName + "; `n" +
            "`nRENAME OBJECT " + $schemaName + "." + $tableName + " TO " + $schemaName + "." + $tableName + "_" + $dateToday + "; `n" +
            "`nRENAME OBJECT " + $schemaName + "." + $tableName + "_CDR1HEAP_NEW TO " + $schemaName + "." + $tableName + "; `n"
        } else {
            $sqlCreateTbl = "/* ******** NONCLUSTERED INDEX ******** */"
        }  
        Write-Output $sqlCreateTbl
        $domainCreateTbl = $domainCreateTbl + $sqlCreateTbl
    }

    # Write-Output $domainCreateTbl 
    $domainCreateTbl | Out-File -FilePath "$folderPath\$domain-CreateBackupTables_$dateToday.sql" -Encoding UTF8 
}
