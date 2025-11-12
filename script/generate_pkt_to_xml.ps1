$date = Get-Date -format "yyyyMMdd"
$name = (git config user.name).Replace(' ', '-').ToLower()
$tag = ("p2x", $name, $date) -Join "/"

git tag $tag
git push origin $tag