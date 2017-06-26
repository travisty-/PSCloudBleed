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

    This command consumes a simple string array of domains, and will work with
    all major password manager export utilities.

    It is strongly suggested that any accounts on matched sites have their
    passwords updated.

    DISCLAIMER: If your source data was exported from a password manager and
    contains passwords, ensure the data is securely disposed of afterwards.
.PARAMETER Name
    Specifies a string array to be passed to the command. This could be in
    the form of a text file imported with Get-Content, or as objects created
    with a command like ConvertFrom-Json or Import-Csv.

    Note that if your source data is represented as objects, you will need to
    explicitly pass in the property you want to use. The name of this property
    varies between password managers.
.EXAMPLE
    PS C:\>
        $content = Get-Content -Path $path
        Get-SitesUsingCloudflare -Name $content

        Passing in an array of sites using Get-Content.
.EXAMPLE
    PS C:\>
        $objects = Import-Csv -Path $path
        Get-SitesUsingCloudflare -Name $objects.Name

        Passing in the "Name" property of an array of objects, using Import-Csv.
.INPUTS
    This command accepts an array of strings as input.
.OUTPUTS
    This command produces a List<PSObject> generic as output.
.LINK
    https://github.com/pirate/sites-using-cloudflare
.LINK
    https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/
.LINK
    https://bugs.chromium.org/p/project-zero/issues/detail?id=1139
.LINK
    https://en.wikipedia.org/wiki/Cloudbleed
.NOTES
    Many thanks to Nick Sweeting (pirate) for taking the initiative
    to compile a comprehensive list of domains that utilize Cloudflare.

    As this list is further updated, the included version may be brought
    up to date by running "git submodule update --remote --merge".

    Note that this list is no longer being maintained, and should be considered
    as an archived resource.
#>
    [CmdletBinding()]
    [OutputType('System.Collections.Generic.List[PSObject]')]

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
