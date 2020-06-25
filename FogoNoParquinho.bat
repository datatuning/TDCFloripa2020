ECHO OFF
"ostress.exe" -E -SGUITORRES-PC\SQL2019 -dStackOverflow2010_TDC -Q"exec dbo.GetTopPosts @OwnerUserId = 2089740" -mstress -quiet -n20 -r50
