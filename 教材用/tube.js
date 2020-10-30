// IFrame Player API の読み込み
var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

// YouTubeの埋め込み
function onYouTubeIframeAPIReady() {
    ytPlayer = new YT.Player(
         'sample', // 埋め込む場所の指定
          {
            width: 640, // プレーヤーの幅
            height: 390, // プレーヤーの高さ
            videoId: 'bHQqvYy5KYo', // YouTubeのID
            playerVars:{
                start: 600
            },
            // イベントの設定
            events: {
            'onReady': onPlayerReady, // プレーヤーの準備ができたときに実行
             'onStateChange': onPlayerStateChange // プレーヤーの状態が変更されたときに実行
            }
        }
     );
  }

  // プレーヤーの準備ができたとき
function onPlayerReady(event) {
    // 動画再生
  event.target.playVideo();
 }
  $(function() {
    // 再生
     $('#play').click(function() {
       ytPlayer.playVideo();
     });
   // 一時停止
   $('#pause').click(function() {
          ytPlayer.pauseVideo();
    });
   // 1分前へ
   $('#prev').click(function() {
       // 現在の再生時間取得
          var currentTime = ytPlayer.getCurrentTime();
          // シークバーの移動
       ytPlayer.seekTo(currentTime - 60);
    });
   // 1分先へ
   $('#next').click(function() {
       // 現在の再生時間取得
          var currentTime = ytPlayer.getCurrentTime();
          // シークバーの移動
       ytPlayer.seekTo(currentTime + 60);
    });
   // 音量アップ(+10)
     $('#volup').click(function() {
          // 現在の音量取得
        var currentVol = ytPlayer.getVolume();
        ytPlayer.setVolume(currentVol + 10);
      });
   // 音量ダウン(-10)
     $('#voldown').click(function() {
        // 現在の音量取得
        var currentVol = ytPlayer.getVolume();
        ytPlayer.setVolume(currentVol - 10);
      });
   // ミュート
   $('#mute').click(function() {
       // ミュートされているかどうか
          if(ytPlayer.isMuted()) {
              // ミュートの解除
            ytPlayer.unMute();
        } else {
              // ミュート
           ytPlayer.mute();
          }
     });
  });

  // プレーヤーの状態が変更されたとき
function onPlayerStateChange(event) {
    // 現在のプレーヤーの状態を取得
    var ytStatus = event.data;
   // 再生終了したとき
  if (ytStatus == YT.PlayerState.ENDED) {
      console.log('再生終了');
       // 動画再生
      event.target.playVideo();
    }
    // 再生中のとき
    if (ytStatus == YT.PlayerState.PLAYING) {
        console.log('再生中');
    }
    // 停止中のとき
    if (ytStatus == YT.PlayerState.PAUSED) {
         console.log('停止中');
    }
    // バッファリング中のとき
   if (ytStatus == YT.PlayerState.BUFFERING) {
      console.log('バッファリング中');
   }
    // 頭出し済みのとき
  if (ytStatus == YT.PlayerState.CUED) {
       console.log('頭出し済み');
  }
 }