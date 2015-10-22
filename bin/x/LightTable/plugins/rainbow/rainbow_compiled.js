if(!lt.util.load.provided_QMARK_('lt.plugins.rainbow')) {
goog.provide('lt.plugins.rainbow');
goog.require('cljs.core');
goog.require('lt.objs.command');
goog.require('lt.objs.command');
goog.require('lt.objs.editor');
goog.require('lt.objs.editor');
goog.require('lt.object');
goog.require('lt.object');

lt.plugins.rainbow.opposites = (function (){var obj7224 = {"]":"[","}":"{",")":"("};return obj7224;
})();

lt.plugins.rainbow.opens = new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 3, ["(",null,"[",null,"{",null], null), null);

lt.plugins.rainbow.closes = new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 3, [")",null,"]",null,"}",null], null), null);

lt.plugins.rainbow.apeek = (function apeek(a){return (a[(a.length - 1)]);
});

lt.plugins.rainbow.overlay = (function overlay(allow_single_quote_strings){return cljs.core.clj__GT_js.call(null,new cljs.core.PersistentArrayMap(null, 2, [new cljs.core.Keyword(null,"startState","startState",3724636353),(function (){var obj7228 = {"rainbowstack":[],"mode":null};return obj7228;
}),new cljs.core.Keyword(null,"token","token",1124445547),(function (stream,state,base){if(!(((function (){var or__5799__auto__ = base.style;if(cljs.core.truth_(or__5799__auto__))
{return or__5799__auto__;
} else
{return "";
}
})().toLowerCase().indexOf("bracket") > -1)))
{(stream["pos"] = base.pos);
return null;
} else
{(stream["pos"] = (base.pos - 1));
var temp__4092__auto__ = stream.next();if(cljs.core.truth_(temp__4092__auto__))
{var cur = temp__4092__auto__;if(cljs.core.truth_(lt.plugins.rainbow.opens.call(null,cur)))
{var level = (new cljs.core.Keyword(null,"level","level",1116770038).cljs$core$IFn$_invoke$arity$2(lt.plugins.rainbow.apeek.call(null,state.rainbowstack),0) + 1);state.rainbowstack.push(new cljs.core.PersistentArrayMap(null, 3, [new cljs.core.Keyword(null,"type","type",1017479852),cur,new cljs.core.Keyword(null,"pos","pos",1014015430),stream.pos,new cljs.core.Keyword(null,"level","level",1116770038),level], null));
return ("rainbow bracket" + level);
} else
{if(cljs.core.truth_(lt.plugins.rainbow.closes.call(null,cur)))
{var prev = lt.plugins.rainbow.apeek.call(null,state.rainbowstack);if(cljs.core._EQ_.call(null,new cljs.core.Keyword(null,"type","type",1017479852).cljs$core$IFn$_invoke$arity$1(prev),(lt.plugins.rainbow.opposites[cur])))
{state.rainbowstack.pop();
return ("rainbow bracket" + new cljs.core.Keyword(null,"level","level",1116770038).cljs$core$IFn$_invoke$arity$2(prev,0));
} else
{return "rainbow bracket-mismatched";
}
} else
{if(new cljs.core.Keyword(null,"else","else",1017020587))
{return null;
} else
{return null;
}
}
}
} else
{return null;
}
}
})], null));
});

lt.plugins.rainbow.__BEH__rainbow_parens = (function __BEH__rainbow_parens(this$){var mode_name = lt.objs.editor.option.call(null,this$,new cljs.core.Keyword(null,"mode","mode",1017261333));var mode = lt.objs.editor.__GT_mode.call(null,this$);var rmode = [cljs.core.str(mode_name),cljs.core.str("-rainbow")].join('');if(cljs.core._EQ_.call(null,mode_name.indexOf("-rainbow"),-1))
{if(cljs.core.truth_((CodeMirror.modes[rmode])))
{} else
{CodeMirror.defineMode(rmode,(function (){return CodeMirror.overlayMode(mode,lt.plugins.rainbow.overlay.call(null,cljs.core.not.call(null,mode.disallowSingleQuoteStrings)),true);
}));
}
lt.objs.editor.set_mode.call(null,this$,rmode);
return lt.object.merge_BANG_.call(null,this$,new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword("lt.plugins.rainbow","real-mode","lt.plugins.rainbow/real-mode",4711707298),mode_name], null));
} else
{return null;
}
});
lt.object.behavior_STAR_.call(null,new cljs.core.Keyword("lt.plugins.rainbow","rainbow-parens","lt.plugins.rainbow/rainbow-parens",565487828),new cljs.core.Keyword(null,"reaction","reaction",4441361819),lt.plugins.rainbow.__BEH__rainbow_parens,new cljs.core.Keyword(null,"desc","desc",1016984067),"Editor: Enable rainbow parens",new cljs.core.Keyword(null,"triggers","triggers",2516997421),new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"object.instant","object.instant",773332388),null], null), null),new cljs.core.Keyword(null,"type","type",1017479852),new cljs.core.Keyword(null,"user","user",1017503549),new cljs.core.Keyword(null,"exclusive","exclusive",2700522000),new cljs.core.PersistentVector(null, 1, 5, cljs.core.PersistentVector.EMPTY_NODE, [new cljs.core.Keyword("lt.plugins.rainbow","hide-rainbow-parens","lt.plugins.rainbow/hide-rainbow-parens",2838693055)], null));

lt.plugins.rainbow.__BEH__hide_rainbow_parens = (function __BEH__hide_rainbow_parens(this$){if(cljs.core.truth_(new cljs.core.Keyword("lt.plugins.rainbow","real-mode","lt.plugins.rainbow/real-mode",4711707298).cljs$core$IFn$_invoke$arity$1(cljs.core.deref.call(null,this$))))
{return lt.objs.editor.set_mode.call(null,this$,new cljs.core.Keyword("lt.plugins.rainbow","real-mode","lt.plugins.rainbow/real-mode",4711707298).cljs$core$IFn$_invoke$arity$1(cljs.core.deref.call(null,this$)));
} else
{return null;
}
});
lt.object.behavior_STAR_.call(null,new cljs.core.Keyword("lt.plugins.rainbow","hide-rainbow-parens","lt.plugins.rainbow/hide-rainbow-parens",2838693055),new cljs.core.Keyword(null,"reaction","reaction",4441361819),lt.plugins.rainbow.__BEH__hide_rainbow_parens,new cljs.core.Keyword(null,"desc","desc",1016984067),"Editor: Disable rainbow parens",new cljs.core.Keyword(null,"triggers","triggers",2516997421),new cljs.core.PersistentHashSet(null, new cljs.core.PersistentArrayMap(null, 1, [new cljs.core.Keyword(null,"object.instant","object.instant",773332388),null], null), null),new cljs.core.Keyword(null,"type","type",1017479852),new cljs.core.Keyword(null,"user","user",1017503549),new cljs.core.Keyword(null,"exclusive","exclusive",2700522000),new cljs.core.PersistentVector(null, 1, 5, cljs.core.PersistentVector.EMPTY_NODE, [new cljs.core.Keyword("lt.plugins.rainbow","rainbow-parens","lt.plugins.rainbow/rainbow-parens",565487828)], null));

}

//# sourceMappingURL=