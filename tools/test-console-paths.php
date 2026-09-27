<?php
/**
 * Checks that the management console works out where it lives, instead of being
 * told, in every layout the site is installed in.
 *
 * The console once had /hotelparadiseonthenile written into it, which was right
 * for exactly one arrangement and broke the site everywhere else. This stands
 * the console in each of them and checks the URLs it would build, which is the
 * one way to be reasonably sure a move to hosting will not bring it back.
 *
 * Run it:  php tools/test-console-paths.php
 */
declare(strict_types=1);

require dirname(__DIR__).'/backend-php/app/bootstrap.php';

/** [label, where the console is, where the domain root is, wanted BASE, wanted SITE_URL] */
$cases=[
 ['domain root, the usual shared hosting',
  '/home/acme/hotelparadiseonthenile/backend-php','/home/acme/hotelparadiseonthenile',
  '/backend-php',''],
 ['a subfolder, the arrangement it used to be hard coded for',
  '/home/acme/public_html/hotelparadiseonthenile/backend-php','/home/acme/public_html',
  '/hotelparadiseonthenile/backend-php','/hotelparadiseonthenile'],
 ['a local project folder, the arrangement that was broken',
  'C:/xampp/htdocs/Hotel_paradise/backend-php','C:/xampp/htdocs',
  '/Hotel_paradise/backend-php','/Hotel_paradise'],
 ['public_html with a named folder',
  '/home/acme/public_html/site/backend-php','/home/acme/public_html',
  '/site/backend-php','/site'],
 ['back slashes, the way Windows reports a path',
  'C:\\xampp\\htdocs\\Hotel\\backend-php','C:\\xampp\\htdocs',
  '/Hotel/backend-php','/Hotel'],
];

$bad=0;
foreach($cases as [$label,$appDir,$docRoot,$wantBase,$wantSite]){
 $p=hp_paths($appDir,$docRoot);

 // The two URLs that were actually returning 404.
 $css=$p['base'].'/assets/admin.css';
 $logo=$p['site'].'/images/logo-256.png';

 // //images/... is a protocol relative address: a browser looks for a host
 // called "images", so a site at the domain root has to produce one slash.
 $okBase=$p['base']===$wantBase;
 $okSite=$p['site']===$wantSite;
 $okLogo=!str_starts_with($logo,'//');
 if(!($okBase&&$okSite&&$okLogo)) $bad++;

 printf("%s %s\n",($okBase&&$okSite&&$okLogo)?'ok  ':'FAIL',$label);
 printf("     stylesheet  %s\n",$css);
 printf("     logo        %s%s\n",$logo,$okLogo?'':'   <- two slashes, this is a broken address');
 printf("     BASE        %s%s\n",$p['base'],$okBase?'':'   wanted '.$wantBase);
 printf("     SITE_URL    %s%s\n",$p['site']===''?'(empty: the site is the whole domain)':$p['site'],$okSite?'':'   wanted '.($wantSite?:'(empty)'));
}

// From a terminal there is no DOCUMENT_ROOT, so this is the folder name alone.
// Over the web the same code is given the real root and answers as above.
$real=hp_paths();
printf("\nwhat this terminal can see (no DOCUMENT_ROOT, so the folder name is all it has)\n     BASE        %s\n     SITE_URL    %s\n",$real['base'],$real['site']===''?'(empty)':$real['site']);

echo "\n",$bad
 ? $bad.' layout(s) wrong'
 : 'all '.count($cases).' layouts resolve correctly',"\n";

exit($bad?1:0);
