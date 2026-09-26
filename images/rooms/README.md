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

- **1200 x 1600 px** (3:4 portrait) or larger. The room card is a portrait
  frame, which suits a bed shot far better than a wide one.
- Shoot the bed straight on, made up, with the room's best feature visible:
  the view, the bathroom, the seating, the desk.
- Daylight, curtains open, no ceiling lights straight down the lens.
- Leave the top fifth of the frame clear; it is where the "Your choice" badge
  sits once a guest picks that room.

## Smaller copies, generated for you

```
python tools/make-derivatives.py
```

Writes `suite-480.jpg` and similar beside each original, and the site picks the
right one per screen. Run it again whenever a photograph changes.

## Checking what is still missing

Add `?photos=1` to the rooms address to see the file name each room is waiting
for.
