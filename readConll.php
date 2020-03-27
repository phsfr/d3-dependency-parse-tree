<html>
<?php
$filePath="data/train.conll";//////"data.txt";//
$myfile = fopen($filePath, "r") or die("Unable to open file!");
$data=fread($myfile,filesize($filePath));
$sents = explode("\n\r", $data);
$i=0;
$sentI=0;
$sentIdArr=array();
foreach($sents as $sent){
	$toks=explode("\n", trim($sent));
	$tokParts=explode("\t", $toks[0]);
	$features=explode("|", $tokParts[5]);
	foreach ($features as $feat) {
		if (strpos( $feat, "senID" ) !== false){
			$senPart=explode("=", $feat);
			$sentI=$senPart[1];
			array_push($sentIdArr,$sentI);
			break;
		}
	}
}

fclose($myfile);
$countSents=sizeof($sents);
if ($_POST) {
	$i=$_POST["indx"];
    if (isset($_POST["nextB"])){
		if ($i < $countSents-1){
			$i=$i+1;
			$tokParts=explode("\t", $sents[$i]);
			$features=explode("|", $tokParts[5]);
			foreach ($features as $feat) {
				if (strpos( $feat, "senID" ) !== false){
					$senPart=explode("=", $feat);
					$sentI=$senPart[1];
				}
			}
		}else{
			echo '<script language="javascript">';
			echo 'alert("به انتهای جملات رسیدید!")';
			echo '</script>';
		}
	}
	elseif(isset($_POST["prevB"])){
		if ($i > 0){
			$i=$i-1;
			$tokParts=explode("\t", $sents[$i]);
			$features=explode("|", $tokParts[5]);
			foreach ($features as $feat) {
				if (strpos( $feat, "senID" ) !== false){
					$senPart=explode("=", $feat);
					$sentI=$senPart[1];
				}
			}
		}else{
			echo '<script language="javascript">';
			echo 'alert("در ابتدای جملات قرار دارید.")';
			echo '</script>';
		}
	}
	elseif(isset($_POST["gotoB"])){
		$senId=$_POST["sentId"];
		$key = array_search($senId, $sentIdArr);
		if($key!=null){
			$i=$key;
		}else{
			echo '<script language="javascript">';
			echo 'alert("جمله مورد نظر بافت نشد.")';
			echo '</script>';
		}
	}
}
?>
<head>
	<meta charset='utf-8'>
	<title>Dependency Parse Tree visualization using d3.js</title>
</head>
<body>
<link rel='stylesheet' href='css/bootstrap.min.css'>
<link rel='stylesheet' href='css/main.css'>
<link rel='stylesheet' href='css/tree.css'>
<script type='text/javascript' src='js/d3.js'></script>
<script type='text/javascript' src='js/dependency-tree.js'></script>

<div class='container'>
	<h2>نمایش درخت وابستگی</h2>
	<div class='tree'>
		<svg height='0'></svg>
	</div>
	<button id='draw' class='btn btn-default' style='visibility:hidden'>نمایش درخت</button>
	<form action="readConll.php" method="post">
		<button name="prevB" id='prev'  class='btn btn-default' >قبلی</button>
		<input name="nextB" type="submit" id='next' class='btn btn-default'  value='بعدی'>
		<input name="indx" id='senId' value="<?php echo $i; ?>">
		<button name="gotoB" id='goto'  class='btn btn-default' >برو به جمله</button>
		<input name="sentId" value="<?php echo $sentIdArr[$i]; ?>">
		<textarea id='myconllu' class='form-control'>
			<?php echo trim($sents[$i]); ?>
		</textarea>
	</form>
</div>
<script type='text/javascript'>
	d3.select('#draw').on('click', function() {
		drawTree('.tree svg',d3.select('#myconllu')[0][0].value, false);
	});
	d3.select('#draw').on('click')();
</script>
</body>
</html>