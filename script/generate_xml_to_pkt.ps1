$date = Get-Date -format "yyyyMMddHHmm"
$name = (git config user.name).Replace(' ', '-').ToLower()
$tag = ("x2p", $name, $date) -Join "/"

git tag $tag
git push origin $tag