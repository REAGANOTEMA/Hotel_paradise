# Room photographs

One photograph per room type. The naming rule matches the room type exactly:
lower case, words joined by hyphens.

| Room type | File name |
| --- | --- |
| Suite | `suite.jpg` |
| Family Room | `family-room.jpg` |
| Triple Room | `triple-room.jpg` |
| Executive Deluxe | `executive-deluxe.jpg` |
| Deluxe Double | `deluxe-double.jpg` |
| Standard Twin | `standard-twin.jpg` |
| Standard Double | `standard-double.jpg` |
| Standard Single | `standard-single.jpg` |

`.jpg`, `.jpeg`, `.png`, `.webp` and `.avif` are all accepted, and the case of
the file name does not matter.

A room with no file is not left as an empty box. The card falls back to a deep
navy panel carrying the bed icon and the bed configuration, so the page still
reads as finished while you are still shooting.

## Recommended size

- **Anything from about 1200px wide upwards.** A wide photograph is fine: the
  copies are cropped to the card for you (see below).
- Shoot the bed straight on, made up, with the room's best feature visible:
  the view, the bathroom, the seating, the desk.
- Daylight, curtains open, no ceiling lights straight down the lens.
- Put the bed in the middle of the frame. The crop takes the middle, so anything
  you want kept has to be near the middle.
- Leave the top fifth of the frame clear; it is where the "Your choice" badge
  sits once a guest picks that room.

## Smaller copies, generated for you

```
python tools/make-derivatives.py
```

Writes `suite-480.jpg` and similar beside each original, and the site picks the
right one per screen. Run it again whenever a photograph changes.

It also **crops every room photograph to the 3:4 card** before making the
copies, so a wide photograph is not cut off by the browser, and the small
copies are cut from the same picture the card shows. Any copies left over from
the photograph it replaces are deleted first, so a phone is never still shown
the old picture. Running it twice does nothing the second time.

If you would rather not have a photograph cropped, keep a copy of the original
outside `/images` before running it, or add the room to the list in
`crop_rooms()` and give it its own ratio.

## Putting a room in the hero carousel

The carousel only reads files named `hero1`, `hero2` ... from `/images`, so a
photograph that is to head the home page is copied in under one of those names:

```
python tools/make-hero.py triple-room.jpg 8
```

That writes `images/hero8.webp`, scaled to 1920px wide and no larger. Run
`make-derivatives.py` afterwards for the smaller copies. The originals stay in
`/images/rooms`, so the room page keeps its portrait crop.

## Checking what is still missing

Add `?photos=1` to the rooms address to see the file name each room is waiting
for. Guests never see it.

