Write-Host "   __  ___     __         _____        __  _ ____         __       ";
Write-Host "  /  |/  /__ _/ /_____   / ___/__ ____/ /_(_) _(_)_______/ /____   ";
Write-Host " / /|_/ / _ `/  '_/ -_)  / /__/ -_) __/ __/ / _/ / __/ _ `/ __/ -_)";
Write-Host "/_/  /_/\_,_/_/\_\\__/  \___/\__/_/  \__/_/_//_/\__/\__/\__/\__/   ";
Write-Host;
Write-Host "Makes certificate files by answering a few simple questions.";
Write-Host "  Learn: http://www.jayway.com/2014/09/03/creating-self-signed-certificates-with-makecert-exe-for-development/.";
Write-Host " Author: Muhammad Rehan Saeed, RehanSaeed.com, @RehanSaeedUK";
Write-Host "Project: https://github.com/RehanSaeed/MakeCertificate"
Write-Host "Version: 1.0";
Write-Host;

$makecert = "C:\Program Files (x86)\Windows Kits\10\bin\x64\makecert.exe";
$pvk2pfx = "C:\Program Files (x86)\Windows Kits\10\bin\x64\pvk2pfx.exe";

do
{
    Write-Host "What type of certificate do you want to create?";
    Write-Host;
    Write-Host "  1 - Certificate Authority (CA) - Equivelant to a certificate from GoDaddy or Verisign but used for development";
    Write-Host "      and testing.";
    Write-Host "  2 - SSL Server Certificate - Handle SSL on the server. This requires a Certificate Authority (CA) Certificate";
    Write-Host "      private and public key file.";
    Write-Host "  3 - Client Certificate - Can be used for client certificate authentication. This requires a Certificate";
    Write-Host "      Authority (CA) Certificate private and public key file.";
    Write-Host;
    $certificateType = Read-Host;
    Write-Host;
}
while (($certificateType -ne '1') -And ($certificateType -ne '2') -And ($certificateType -ne '3'))

do
{
    Write-Host "Certificate name?";
    $certificateName = Read-Host;
    Write-Host;
}
while (!$certificateName)

if ($certificateType -eq '1' -Or $certificateType -eq '3')
{
    $subject = "CN=$certificateName";

    Write-Host "Organizational unit name e.g. Dev (Optional)?";
    $organizationalUnitName = Read-Host;
    Write-Host;
    if ($organizationalUnitName)
    {
        $subject = "$subject,OU=$organizationalUnitName";
        
    }

    Write-Host "Organization  name e.g. Microsoft (Optional)?";
    $organizationName = Read-Host;
    Write-Host;
    if ($organizationName)
    {
        $subject = "$subject,O=$organizationName";
    }

    Write-Host "Locality e.g. San Francisco (Optional)?";
    $localityName = Read-Host;
    Write-Host;
    if ($localityName)
    {
        $subject = "$subject,L=$localityName";
    }

    Write-Host "State or province e.g. CA (Optional)?";
    $stateOrProvinceName = Read-Host;
    Write-Host;
    if ($stateOrProvinceName)
    {
        $subject = "$subject,S=$stateOrProvinceName";
    }

    Write-Host "Country e.g. US (Optional)?";
    $countryName = Read-Host;
    Write-Host;
    if ($countryName)
    {
        $subject = "$subject,C=$countryName";
    }
}
elseif ($certificateType -eq '2')
{
    do
    {
        Write-Host "Domain name e.g. example.com, www.example.com or *.example.com?";
        $domainName = Read-Host;
        Write-Host;
    }
    while (!$domainName)
    $subject = "CN=$domainName";
}

if ($certificateType -eq '2' -Or $certificateType -eq '3')
{
    do
    {
        Write-Host "Issuer Certificate Authority (CA) private key file path e.g. C:\key.pvk ?";
        $issuerPvk = Read-Host;
        Write-Host;
    }
    while (!$issuerPvk)

    do
    {
        Write-Host "Issuer Certificate Authority (CA) public key file path e.g. C:\key.cer ?";
        $issuerCer = Read-Host;
        Write-Host;
    }
    while (!$issuerCer)

    Write-Host "Certificate start date e.g. 01/01/2014 (Optional - Leave blank for yesterdays date)?";
    $startDate = Read-Host;
    Write-Host;
    if (!$startDate)
    {
        $startDate = (get-date).AddDays(-1).ToString("MM/dd/yyyy")
    }

    Write-Host "Certificate end date e.g. 01/01/2100 (Optional - Leave blank for one hundred years in the future)?";
    $endDate = Read-Host;
    Write-Host;
    if (!$endDate)
    {
        $endDate = (get-date).AddYears(100).ToString("MM/dd/yyyy")
    }
}

Write-Host "Signature algorithm e.g. MD5, SHA1, SHA256, SHA384, SHA512 (Optional - defaults to SHA512)?";
$signatureAlgorithm = Read-Host;
Write-Host;
if (!$signatureAlgorithm)
{
    $signatureAlgorithm = "SHA512";
}

Write-Host "Key length e.g. 4096 (Optional - defaults to 4096)?";
$keyLength = Read-Host;
Write-Host;
if (!$keyLength)
{
    $keyLength = "4096";
}

do
{
    do
    {
        Write-Host "Password for the PKCS (.pfx file), not to be confused with the private key password?";
        $password = Read-Host;
        Write-Host;
    }
    while (!$password)

    Write-Host "Confirm password";
    $confirmPassword = Read-Host;
    Write-Host;
}
while (!$confirmPassword -And ($password -ne $confirmPassword))

try
{
    if ($certificateType -eq '1')
    {
        Write-Host "Making Certificate Authority (CA) Certificate";
        Write-Host "   Name: $certificateName";
        Write-Host "Subject: $subject";
        Write-Host;

        Write-Host "$makecert -n `"$subject`" -r -pe -a $signatureAlgorithm -len $keyLength -cy authority -sv `"$certificateName.pvk`" `"$certificateName.cer`"";
        & $makecert -n $subject -r -pe -a $signatureAlgorithm -len $keyLength -cy authority -sv "$certificateName.pvk" "$certificateName.cer";
    }
    elseif ($certificateType -eq '2')
    {
        Write-Host "Making SSL Server Certificate";
        Write-Host "   Name: $certificateName";
        Write-Host "Subject: $subject";
        Write-Host;

        Write-Host "$makecert -n `"$subject`" -iv $issuerPvk -ic $issuerCer -pe -a $signatureAlgorithm -len $keyLength -b $startDate -e $endDate -sky exchange -eku 1.3.6.1.5.5.7.3.1 -sv `"$certificateName.pvk`" `"$certificateName.cer`"";
        & $makecert -n $subject -iv $issuerPvk -ic $issuerCer -pe -a $signatureAlgorithm -len $keyLength -b $startDate -e $endDate -sky exchange -eku 1.3.6.1.5.5.7.3.1 -sv "$certificateName.pvk" "$certificateName.cer";
    }
    elseif ($certificateType -eq '3')
    {
        Write-Host "Making Client Certificate";
        Write-Host "   Name: $certificateName";
        Write-Host "Subject: $subject";
        Write-Host;

        Write-Host "$makecert -n `"$subject`" -iv $issuerPvk -ic $issuerCer -pe -a $signatureAlgorithm -len $keyLength -b $startDate -e $endDate -sky exchange -eku 1.3.6.1.5.5.7.3.2 -sv `"$certificateName.pvk`" `"$certificateName.cer`"";
        & $makecert -n $subject -iv $issuerPvk -ic $issuerCer -pe -a $signatureAlgorithm -len $keyLength -b $startDate -e $endDate -sky exchange -eku 1.3.6.1.5.5.7.3.2 -sv "$certificateName.pvk" "$certificateName.cer";
    }

    Write-Host "$pvk2pfx -pvk `"$certificateName.pvk`" -spc `"$certificateName.cer`" -pfx `"$certificateName.pfx`" -po $password";
    & $pvk2pfx -pvk "$certificateName.pvk" -spc "$certificateName.cer" -pfx "$certificateName.pfx" -po $password;
}
catch
{
    Write-Host "makecert.exe or pvk2pfx.exe was not found. Looked in these locations: $makecert $pvk2pfx";
    Write-Host;
}