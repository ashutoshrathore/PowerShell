$filename = "C:\sample.key"
[Convert]::ToBase64String([IO.File]::ReadAllBytes($filename)) | clip
