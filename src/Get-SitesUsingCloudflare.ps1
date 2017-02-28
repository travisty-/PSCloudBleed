#Requires -Version 5

using namespace System.Collections.Generic
using namespace System.IO

function Get-SitesUsingCloudflare {
<#
.SYNOPSIS
    Cross references sites with a list of domains possibly affected by the
    CloudBleed HTTPS traffic leak.
.DESCRIPTION
    Get-SitesUsingCloudflare cross references sites with a list of domains
    possibly affected by the CloudBleed HTTPS traffic leak. This list contains
    all domains that use Cloudflare, not just the Cloudflare proxy
    (the affected service that leaked data).

    This cmdlet consumes a simple string array of domains, and will work with
    all major password manager export utilities.

    It is strongly suggested that any accounts on matched sites have their
    passwords updated.

    DISCLAIMER: IF YOUR SOURCE DATA WAS EXPORTED FROM A PASSWORD MANAGER AND
    INCLUDES PASSWORDS, SECURELY DISPOSE OF THE DATA AFTERWARDS.
.PARAMETER Name
    Specifies the name of the array to be passed to the cmdlet. This may be
    anything from a text file using Get-Content, to a .csv object created with
    Import-Csv. Note that if your source data is represented as an object,
    passing in the correct property (i.e. column) is requred using the
    $object.Property syntax. This property name varies between
    password managers.
.EXAMPLE
    Get-SitesUsingCloudflare -Name $array
    Passing in an array, possibly from Get-Content.
.EXAMPLE
    Get-SitesUsingCloudflare -Name $csv.Name
    Passing in the 'Name' property of a .csv object, from Import-Csv.
.INPUTS
    This command accepts an array of strings as input.
.OUTPUTS
    This command produces a List<String> generic as output, however it's
    intended use is as a pipeline input for a cmdlet such as Out-File or
    Export-Csv.
.LINK
    https://github.com/pirate/sites-using-cloudflare
.LINK
    https://en.wikipedia.org/wiki/Cloudbleed
.LINK
    https://bugs.chromium.org/p/project-zero/issues/detail?id=1139
.LINK
    https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/
.NOTES
    Many thanks to Nick Sweeting for taking the initiative to complile
    a comprehensive list of domains that utilize Cloudflare.

    As this list is further updated, the included version may be brought
    up to date by running "git submodule update".
#>
    [CmdletBinding()]
    [OutputType([List[PSObject]])]

    param(
        [Parameter(Mandatory,
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Name
    )

    begin {
        $results = [List[PSObject]]::new()

        Write-Verbose -Message 'Searching for source file...'
        $file = "$PSScriptRoot\..\lib\sites-using-cloudflare\sorted_unique_cf.txt"

        if (-not(Test-Path -Path $file)) {
            throw [FileNotFoundException] 'Source file not found. Ensure "sorted_unique_cf.txt" is located in "PSCloudBleed\lib\sites-using-cloudflare".'
        } #if

        Write-Verbose -Message 'Source file found. Initializing file reader...'
        $sites = [File]::ReadLines($file)
    } #begin

    process {
        Write-Verbose -Message 'Enumerating source file content...'
        foreach ($site in $sites) {
            if ($Name -contains $site) {

                Write-Verbose -Message "Match detected! $site is using Cloudflare."
                $siteObject = [pscustomobject] @{
                    Name = $site
                }

                [void] $results.Add($siteObject)
            } #if
        } #foreach

        Write-Verbose -Message 'Source file enumeration complete! Returning results...'
        return $results
    } #process
} #function
