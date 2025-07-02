call bundle exec jekyll build --base /~unicorn
move _site htdocs
zip -r htdocs.zip htdocs
move htdocs _site
scp htdocs.zip unicorn@ws1.csie.ntu.edu.tw:~/
ssh unicorn@ws1.csie.ntu.edu.tw "echo A | unzip htdocs"
del htdocs.zip

call bundle exec jekyll build --base /~b12902079
move _site htdocs
zip -r htdocs.zip htdocs
move htdocs _site
scp htdocs.zip b12902079@ws1.csie.ntu.edu.tw:~/
ssh b12902079@ws1.csie.ntu.edu.tw "echo A | unzip htdocs"
del htdocs.zip