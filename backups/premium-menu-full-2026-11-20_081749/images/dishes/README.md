# Dish photographs

Drop pictures in this folder. The menu picks them up on the next build, and the
naming rule is the only thing you have to get right.

## Naming rule

The file name must match the slug of the dish: lower case, words joined by
hyphens, then the extension. So **Mushroom Soup** looks for `mushroom-soup.jpg`.

`.jpg`, `.jpeg`, `.png`, `.webp` and `.avif` are all accepted, and the case of
the file name does not matter.

A dish with no file still looks finished. The card shows a warm printed plate
with the course name on it, never an empty box and never a broken image.

## Section banners

Each section also has a banner strip with the section name laid over it. Name
it `section-<key>.jpg`:

| Section | File name |
| --- | --- |
| Starters | `section-starters.jpg` |
| Egg Dishes | `section-eggs.jpg` |
| Burgers | `section-burgers.jpg` |
| Wraps and Rolex | `section-wraps.jpg` |
| Snacks | `section-snacks.jpg` |
| Italian Special Pastas | `section-pasta.jpg` |
| Fisherman's Offer | `section-wholefish.jpg` |
| Fish Fillets | `section-fillets.jpg` |
| Chicken Lovers | `section-chicken.jpg` |
| Paradise Hunter's Delicacies | `section-steaks.jpg` |
| Pork | `section-pork.jpg` |
| House Specials | `section-house.jpg` |
| Asian Delicacies | `section-asian.jpg` |
| Desserts | `section-desserts.jpg` |
| Pizzeria Section | `section-pizza.jpg` |

Banners are cropped to a very wide strip. Shoot or crop to at least
**2000 x 760 px**, and keep the interesting part on the **right**, because a
navy gradient is laid over the left where the section name sits.

## Recommended size for dish photos

- **1200 x 900 px** (4:3) or larger. The card is a 4:3 frame and anything
  narrower gets cropped.
- Shoot on a light plain background, plate slightly off centre, soft daylight.
- Landscape orientation. Portrait photos get cut into the 4:3 frame.
- Keep faces and hands out of the top of the frame; the frame crops evenly.

A phone photo taken in good light is usually enough. What is not enough is a
photo that has been shrunk down to thumbnail size before it reaches this folder,
because no browser can put the detail back.

## Smaller copies, generated for you

After you add photographs, run this from the project folder:

```
python tools/make-derivatives.py
```

It writes narrower copies beside each original, for example
`mushroom-soup-480.jpg`, and the site then hands every screen the smallest file
that still covers it. Run it again any time you add or replace a photograph.
It needs Pillow: `pip install pillow`.

## Checking what is still missing

Add `?photos=1` to the menu address and each card that is still waiting for a
photograph shows the exact file name it wants. Remove `?photos=1` before
sharing the link with guests.

To see what you already have:

```
Get-ChildItem .\images\dishes\*.jpg | Select-Object -ExpandProperty Name
```
