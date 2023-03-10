# swift text-rank summarizing demo

test program for [Reductio](https://github.com/RayKitajima/Reductio) text rank algorithm implementation.

```bash
$ swift build
$ .build/debug/SwiftSummarizer <url-or-file-path> --target-size <int> --timeout <double>
``` 

example

```bash
$ .build/debug/SwiftSummarizer https://www.theverge.com/2023/3/9/23629372/twitter-tumblr-livejournal-social-network --target-size 3096 --timeout 5
```

License (MIT)
