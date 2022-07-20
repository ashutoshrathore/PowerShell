function Get-AccessToken
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,ParameterSetName='Resource')]
        [Parameter(Mandatory=$true,ParameterSetName='Scope')]
        [string]$ClientId,
        
        [Parameter(Mandatory=$true,ParameterSetName='Resource')]
        [Parameter(Mandatory=$true,ParameterSetName='Scope')]
        [string]$ClientSecret,
        
        [Parameter(Mandatory=$true,ParameterSetName='Resource')]
        [Parameter(Mandatory=$true,ParameterSetName='Scope')]
        [string]$TenantId,
        
        [Parameter(Mandatory=$true,ParameterSetName='Resource')]
        [string]$Resource,
        
        [Parameter(Mandatory=$true,ParameterSetName='Scope')]
        [string]$Scope
    )

    begin
    {
        $body = @{ 
                    "grant_type"    = "client_credentials" 
                    "client_id"     = $ClientId
                    "client_secret" = $ClientSecret
                 }

        switch ( $PSCmdlet.ParameterSetName )
        {
            "Resource"
            {
                $body["resource"] = $Resource
            }
            "Scope"
            {
                $body["scope"] = $Scope
            }
        }
    }
    process
    {
        Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token -Method Post -Body $body | SELECT -ExpandProperty access_token
    }
    end
    {
    }
}

function Get-AzureActiveDirectoryUser
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline=$false)][string]$UserPrincipalName,
        [Parameter(ValueFromPipeline=$true)][string]$AccessToken
    )

    begin
    {
        $headers = @{ 'Authorization' = "Bearer $($AccessToken)" }    
    }
    process
    {
        try
        {
            Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$UserPrincipalName" –Headers $headers –Method GET
        }
        catch
        {
            if( $_.Exception.Response.StatusCode.value__ -ne 404 )
            {
                throw $_.Exception
            }
        }
    }
    end
    {
    }
}

function Get-VaultSecret
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$true)][string]$AccessToken,
        [parameter(Mandatory=$true)][string]$SecretName,
        [parameter(Mandatory=$true)][string]$VaultBaseUrl,
        [parameter(Mandatory=$true)][string]$SecretVersion
    )
    
    begin
    {
        $headers = @{ "Authorization" = "Bearer $AccessToken" }

        $url = "$VaultBaseUrl/secrets/$SecretName/$($SecretVersion)?api-version=2016-10-01"
    }
    process
    {
        Invoke-RestMethod -Method Get -Uri $url -Headers $headers | SELECT -ExpandProperty value
    }
    end
    {
    }    
}

# inspiration:
# https://medium.com/@anoopt/accessing-azure-key-vault-secret-through-azure-key-vault-rest-api-using-an-azure-ad-app-4d837fed747

$clientId      = "a59cac14-1234-1234-1234-4c8ef3603194"
$clientSecret  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$tenantId      = "72f988bf-1234-1234-1234-2d7cd011db47"
$scope         = "https://vault.azure.net/.default"
$secretName    = "xxxxxxxxxxx"
$secretVersion = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$vaultBaseUrl  = "https://xxxxxxxxxx.vault.azure.net"

$accessToken = Get-AccessToken -ClientId $clientId -ClientSecret $clientSecret -TenantId $tenantId -Scope $scope

$value = Get-VaultSecret -VaultBaseUrl $vaultBaseUrl -AccessToken $accessToken -SecretName $secretName -SecretVersion $secretVersion -ApiVersion "2016-10-01" 

 
