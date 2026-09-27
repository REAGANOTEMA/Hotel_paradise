<?php
declare(strict_types=1);

/**
 * COMPANIONS AND SALADS
 *
 * The prices the website offers a guest for a companion or a salad. The
 * website sends only the keys it was shown, never an amount, so the
 * total on a takeaway order is worked out here from this list and the
 * price already held in menu_items. A key that is not in this list is
 * dropped rather than trusted.
 *
 * To make every companion and salad free, set every add to 0 here. The
 * pickers on the website keep working and the totals stop moving.
 *
 * This list must be kept in step with COMPANIONS and SALADS in
 * frontend-react/src/menuData.ts.
 */
const MENU_COMPANIONS=[
  'chips'   =>['name'=>'Chips',           'add'=>0],
  'rice'    =>['name'=>'Steamed rice',    'add'=>0],
  'roll'    =>['name'=>'Bread roll',      'add'=>0],
  'none'    =>['name'=>'As it comes',     'add'=>0],
  'fries'   =>['name'=>'French fries',    'add'=>3000],
  'wedges'  =>['name'=>'Potato wedges',   'add'=>4000],
  'pilau'   =>['name'=>'Brown pilau rice','add'=>4000],
  'matoke'  =>['name'=>'Matoke',          'add'=>4000],
  'chapatti'=>['name'=>'Chapatti',        'add'=>3000],
  'ugali'   =>['name'=>'Ugali',           'add'=>3000],
  'cassava' =>['name'=>'Cassava',         'add'=>3000],
  'garlic'  =>['name'=>'Garlic bread',    'add'=>5000],
  'naan'    =>['name'=>'Naan',            'add'=>5000]
];

const MENU_SALADS=[
  'coleslaw'=>['name'=>'Coleslaw',              'add'=>5000],
  'green'   =>['name'=>'Green salad',           'add'=>5000],
  'cucumber'=>['name'=>'Cucumber and tomato',   'add'=>5000],
  'caesar'  =>['name'=>'Caesar salad',          'add'=>9000],
  'russian' =>['name'=>'Russian salad',         'add'=>8000],
  'veggie'  =>['name'=>'Grilled Veggies Salad', 'add'=>18000],
  'tuna'    =>['name'=>'Tuna Salad',            'add'=>20000]
];

/** A key that exists, or null. Never returns anything the guest made up. */
function menu_extra(string $key, array $list): ?array{
  $k=strtolower(trim($key));
  return ($k!==''&&isset($list[$k]))?$list[$k]+['key'=>$k]:null;
}
