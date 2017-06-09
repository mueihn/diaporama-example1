##
# generate the files.xml listing the input photos and advertisements
##
$filesStream = New-Object System.IO.MemoryStream
$filesWriter = [System.Xml.XmlWriter]::Create($filesStream)
$filesWriter.WriteStartDocument()
$filesWriter.WriteStartElement("files")
$filesWriter.WriteStartElement("photos")
Get-Childitem -Path .\photos -Recurse -Include *.JPG,*.JPEG,*.PNG -File |
Foreach-Object {
    $relPath = "."+$_.FullName.Substring((Resolve-Path .\).Path.Length)
    $relPath = $relPath.Replace("\","/")
    $filesWriter.WriteElementString("photo", $relPath)
}
$filesWriter.WriteEndElement()
$filesWriter.WriteStartElement("advertisements")
Get-Childitem -Path .\advertisements -Recurse -Include *.JPG,*.JPEG,*.PNG -File |
Foreach-Object {
	$relPath = "."+$_.FullName.Substring((Resolve-Path .\).Path.Length)
    $relPath = $relPath.Replace("\","/")
    $filesWriter.WriteElementString("advertisement", $relPath)
}
$filesWriter.WriteEndElement()
$filesWriter.WriteEndElement()
$filesWriter.WriteEndDocument()
$filesWriter.Flush()
$filesWriter.Close()


##
# generate the actual slideshow file from the input XML and the config XML
##
$sortFilesXslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$sortFilesXslt.Load("sortFiles.xslt");
$filesStream.Seek(0,[System.IO.SeekOrigin]::Begin)
$filesReader = [System.Xml.XmlReader]::Create($filesStream)
$sortedFilesStream = New-Object System.IO.MemoryStream
$sortedFilesWriter = [System.Xml.XmlWriter]::Create($sortedFilesStream)
$sortFilesXslt.Transform($filesReader, $sortedFilesWriter);

$generateJsonXslt = New-Object System.Xml.Xsl.XslCompiledTransform;
$generateJsonSettings = New-Object System.Xml.Xsl.XsltSettings;
$generateJsonSettings.EnableDocumentFunction = $true
$generateJsonXslt.Load("generateDiaporamaJson.xslt", $generateJsonSettings, $null);
$sortedFilesStream.Seek(0,[System.IO.SeekOrigin]::Begin)
$sortedFilesReader = [System.Xml.XmlReader]::Create($sortedFilesStream)
$jsonStream = New-Object System.IO.FileStream("diaporama.json", [System.IO.FileMode]::Create)
$generateJsonXslt.Transform($sortedFilesReader, $null, $jsonStream);


##
# run the slideshow
##
. ((Resolve-Path .\).Path.ToString()+'\slideshow.ps1')