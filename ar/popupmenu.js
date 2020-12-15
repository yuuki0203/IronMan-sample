/**
 * @description ポップアップメニュー表示クラス
 * @param{Object} jQueryCommon 利用するjQuery オブジェクトを渡す。静的に使いまわすので、2回目以降はNULL指定可能。
 * @param{Object} menuList 表示するポップアップメニューリスト。title, action メンバを持つこと。
 */ 
function PopupMenu( jQueryCommon, menuList ){
    /**
     * @description ポップアップメニューに表示するリスト。title, action メンバを持つ。
     */
    this.itsMenuList = menuList;
    /**
     * @description 設定されたポップアップメニューの最大文字列。デフォルト14文字。
     */
    this.itsMaxStringLength = (function( list, defaultLength ){
        var i, n = list.length, title, action;
        for( i=0; i<n; i++ ){
            title = list[i].title;
            action = list[i].action;
            if( (title && action) && ( defaultLength < title.length ) ){
                defaultLength = title.length;
            }
        }
        return defaultLength;
    }(menuList, 14));

    this.itsId = "_id_popup"; // ※init()の中で数字を付加してユニーク化される。
    this.init( jQueryCommon );
};
(function(){
    /**
     * @description ポップアップメニューのdiv要素CSS
     */
    var MENU_DIV_CSS = {
        "position" : "absolute",
        "min-width" : "100px",
        "background-color" : "#eeeeee",
        "border": "1pt solid #666666",
        "box-shadow" : "2px 2px 4px 0px #666666"
    };
    /**
     * @description ポップアップメニューのulタグのCSS
     */
    var MENU_UL_CSS = {
        "border": "0pt",
        "margin" : "2px",
        "padding" : "6px",
        "line-height": "12pt",
        "color": "#000",
        "list-style" : "none",
        "font-size" : "11pt"
    };
    /**
     * @description ポップアップメニュー項目のCSS
     */
    var LI_CSS = {
        "padding" : "6px",
        "background-color" : "#eeeeee",
        "border" : "1px solid transparent",
        "font-size" : "18px"
    };
    /**
     * @description ポップアップメニュー項目のHover時のCSS
     */
    var LI_CSS_HOVER = {
        "background-color" : "#d1e2f2",
        "border" : "1px solid #78aee5"
    }; // http://www.tohoho-web.com/wwwxx035.htm
    /**
     * @description このクラスで利用するjQuery。
     */
    var jQ = null;
    /**
     * @description 生成されたポップアップメニューIDのリスト。
     */
    var menuIds = [];
    /**
     * @description 全てのポップアップメニューを非表示にする。
     * @param{String} exceptId 捜査対象外のID。null指定なら、全部を「非表示」にする。
     */
    var hideAll = function( exceptId ){
        var n = menuIds.length;
        var target;
        while( 0<n-- ){
            target = jQ("#" + menuIds[n]);
            if( (menuIds[n] != exceptId) && (target.size() > 0) ){
                target.hide();
            }
        }
    }
    /**
     * @description 最近のshow()で渡された、第一引数Eventと、第二引数。
     */
    var staticLastEvent = null, staticLastParam = null;
    /**
     * @description 本クラスの初期化。
     * @param{Object} initJQuery jQueryオブジェクトを渡す。初回以降はnullでも構わない。
     */
    PopupMenu.prototype.init = function( initJQuery ){
        var BIND_INDEX_ATTR = "data-action-index";
        var i, list = this.itsMenuList, n = list.length, str, title, action;
        var target, item;
        jQ = (!jQ) ? initJQuery : jQ;
        this.itsId += "_" + menuIds.length;
        target = jQ("body");
        target.append( "<div id='" + this.itsId + "' style='display:none;'><div>" );
        target = jQ("#" + this.itsId);
        target.css( MENU_DIV_CSS );

        str = "<ul>";
        for( i=0; i<n; i++ ){
            title = list[i].title;
            action = list[i].action;
            if( title && action ){
                str += "<li " + BIND_INDEX_ATTR + "='" + i + "'>" + title + "</li>";
            }
        }
        str += "</ul>";
        target.append( str );

        target = target.children("ul").eq(0);
        target.css( MENU_UL_CSS );

        target = jQ("#" + this.itsId + " ul li" );
        target.css( LI_CSS );
        target.hover( 
            function(){ jQ(this).css( LI_CSS_HOVER ); },
            function(){ jQ(this).css( LI_CSS ); } 
        );
        target.click(function(event){
            var item = jQ(this);
            var index = item.attr( BIND_INDEX_ATTR );
            hideAll(null);
            list[ index ].action( staticLastEvent, staticLastParam );
        })

        menuIds.push( this.itsId );
    }
    /**
     * @description ポップアップメニューを表示する。
     * 　　　　　　　メニュー以外の場所をクリックすると消える。他のポップアップメニューが表示された時も、以前のは消える。
     * @param{event} event jQuery.click(function(event){})で渡されるeventオブジェクトを指定する。
     * 　　　　　　　　　　　呼び出し先の関数の引数にそのまま渡す。
     * @param{Object} paramObj newの際のactionパラメータに指定された関数呼び出し時の第二引数に渡される。
     * 　　　　　　　　　　　　　通常はthisを渡すこと。
     */
    PopupMenu.prototype.show = function(event, paramObj){
        /*
        [メモ] click() はeventが渡される仕様。
        ---
        jQueryのイベントは、コールバック関数の最初の引数でjQuery.Eventオブジェクトを受け取ることができます。
        このオブジェクトを使って、規定のイベント動作のキャンセルや、バブリングの抑制などを行います
        http://semooh.jp/jquery/api/events/click/fn/
        */
        var target = jQ("#" + this.itsId);
        var isShowed = (target.css("display") == "none");
        var pos;

        hideAll( this.itsId );
        if( isShowed ){
            pos = this.getMenuPosition( event );
            target.css({
                "top" : (pos.pageY+20) + "px",
                "left" : (pos.pageX-50) + "px",
            });
            target.slideDown("fast");
            staticLastEvent = event;
            staticLastParam = paramObj;
        }else{
            target.hide();
        }
    };
    /**
     * @description ポップアップメニュー表示毎に、表示位置決めのためにcallbackされる。
     *              サブクラスで任意にオーバーライドのこと。
     */
    PopupMenu.prototype.getMenuPosition = function( event ){
        return { "pageX" : event.pageX, "pageY" : event.pageY };
    };
    /**
     * @description 表示中のポップアップメニューを全て非表示にする。
     */
    PopupMenu.prototype.hide = function(){
        hideAll( null );
    };
}());