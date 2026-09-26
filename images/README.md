# Website photographs

Everything the site displays as a picture lives in this folder tree. The build
scans it and generates `frontend-react/src/image-manifest.json`, so the pages
know what exists before a single byte is downloaded.

```
images/
  hero1.jpg ... hero7.jpg    the home page carousel
  dishes/                    one photo per dish, plus section-<key>.jpg banners
  rooms/                     one photo per room type
  gallery/                   anything else, ready to use
```

`images/dishes/README.md` and `images/rooms/README.md` have the exact file
names and the recommended sizes.

## Two rules that decide whether a photo looks sharp

1. **Never save a photograph smaller than the frame it fills.** A dish card is
   4:3, a room card is 3:4, a section banner is very wide. Handing a browser a
   file smaller than the box it has to fill is what makes a picture look
   blurry, and it cannot be undone in CSS.
2. **Run `python tools/make-derivatives.py` after adding photographs.** It makes
   the narrow copies so a phone is never asked to download a desktop sized
   file, which keeps the page fast on Ugandan mobile data.

## The current carousel files are too small

`hero1` through `hero7` are between 382px and 680px wide, and they are used
full screen. At that size they cannot be sharp on a laptop, let alone a 4K
display. Replace them with the originals from the camera or the photographer.
Landscape is best, at least **2400px wide**; `hero1` is currently portrait and
will be cropped.

Until they are replaced the carousel still works, it is just the one soft part
of the site.

## Naming

Lower case, words joined by hyphens. `.jpg`, `.jpeg`, `.png`, `.webp` and
`.avif` are all accepted and the case of the file name does not matter.
