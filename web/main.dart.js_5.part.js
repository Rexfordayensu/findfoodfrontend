((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={zm:function zm(d,e){this.c=d
this.a=e},a4n:function a4n(d){this.a=d},aIX:function aIX(d){this.a=d},Aq:function Aq(d,e){this.c=d
this.a=e},Q4:function Q4(){this.d=!1
this.c=this.a=null},aWg:function aWg(d){this.a=d},aWh:function aWh(d){this.a=d},acp:function acp(d,e){this.c=d
this.a=e},b6v:function b6v(d){this.a=d},b6w:function b6w(d,e){this.a=d
this.b=e},
XQ(d,e,f){var w=0,v=A.q(x.y),u,t,s,r
var $async$XQ=A.m(function(g,h){if(g===1)return A.n(h,v)
for(;;)switch(w){case 0:s=A.Kc("POST",A.aq(y.b,0,null))
s.r.n(0,"Authorization","Bearer "+f)
s.y.push(A.Kb("file",e,A.GA(d),d))
r=A
w=4
return A.h($.aE().ex(0,s),$async$XQ)
case 4:w=3
return A.h(r.q_(h),$async$XQ)
case 3:t=h
if(t.b===200){u=A.bf(t)
w=1
break}throw A.i(A.ag(A.bo(t,"Could not upload your photo")))
case 1:return A.o(u,v)}})
return A.p($async$XQ,v)},
alB(d){var w=0,v=A.q(x.y),u,t,s
var $async$alB=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.w
w=3
return A.h($.aE().tF(0,A.aq(y.b,0,null),A.J(["Authorization","Bearer "+d],t,t)),$async$alB)
case 3:s=f
if(s.b===200){u=A.bf(s)
w=1
break}throw A.i(A.ag(A.bo(s,"Could not remove your photo")))
case 1:return A.o(u,v)}})
return A.p($async$alB,v)}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[10],C)
D=c[14]
C.zm.prototype={
t(d){var w,v,u=null,t=A.af(d,!0,x.e),s=t.f,r=s==null?u:B.d.a4(s).length!==0
if(r===!0){s.toString
w=s}else w="Your account"
s=x.u
r=A.a([A.j(w,B.Kp,u,u,u,A.t(u,u,A.c(d).ax.a===B.b?B.t:B.r,u,u,u,u,u,u,u,u,18,u,u,B.A,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u)],s)
v=t.r
if(v!=null&&v.length!==0)r.push(A.j(v,B.Kn,u,u,u,A.t(u,u,A.c(d).ax.a===B.b?B.v:B.u,u,u,u,u,u,u,u,u,13,u,u,u,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u))
r.push(new A.Z(B.oY,A.j(this.c,u,u,u,u,B.t1,u,u,u,u),u))
return A.R(A.a([D.U0,B.dE,A.aa(A.W(r,B.p,u,B.e,B.f,0,B.k),1)],s),B.i,u,B.e,B.f,0,u)}}
C.a4n.prototype={
t(d){return new A.AO("Sign out",new C.aIX(d),B.Kj)}}
C.Aq.prototype={
L(){return new C.Q4()}}
C.Q4.prototype={
mP(){var w=0,v=A.q(x.v),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g
var $async$mP=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:h=q.c
h.toString
p=A.af(h,!1,x.e)
h=p.w
if(h==null)h=""
j=q.c
j.toString
w=3
return A.h(A.dL(j,new C.acp(h.length!==0,null),x.w),$async$mP)
case 3:o=e
if(o==null||q.c==null){w=1
break}q.p(new C.aWg(q))
t=5
w=o==="remove"?8:9
break
case 8:h=p.c
h.toString
w=10
return A.h(C.alB(h),$async$mP)
case 10:n=e
h=J.A(n,"avatar_url")
h=h==null?null:J.bM(h)
w=11
return A.h(p.vg(h),$async$mP)
case 11:h=q.c
if(h!=null)A.b0(h,"Photo removed.",!1)
r=[1]
w=6
break
case 9:w=12
return A.h(new A.pp().uH(85,800,800,B.i2),$async$mP)
case 12:m=e
if(m==null){r=[1]
w=6
break}h=p.c
h.toString
w=13
return A.h(m.p7(),$async$mP)
case 13:j=e
w=14
return A.h(C.XQ(m.b,j,h),$async$mP)
case 14:l=e
h=J.A(l,"avatar_url")
h=h==null?null:J.bM(h)
w=15
return A.h(p.vg(h),$async$mP)
case 15:h=q.c
if(h!=null)A.b0(h,"Looking good! Photo updated.",!1)
r.push(7)
w=6
break
case 5:t=4
g=s.pop()
k=A.a4(g)
h=q.c
if(h!=null)A.b0(h,A.b5(k),!0)
r.push(7)
w=6
break
case 4:r=[2]
case 6:t=2
if(q.c!=null)q.p(new C.aWh(q))
w=r.pop()
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$mP,v)},
t(d){var w,v,u=this,t=null,s=A.af(d,!0,x.e),r=u.a.c,q=u.d?t:u.gaqh(),p=r+4,o=A.a([new A.DB(s.f,s.w,r,t)],x.u)
if(u.d){w=r*0.36
o.push(A.L_(4,A.brv(A.A5(A.c3(A.br(D.OG,w,w),t,t),B.oq,!0)),4))}w=r*0.38
v=A.aW(A.c(d).ax.a===B.b?B.bY:B.y,B.n,2)
o.push(A.h9(0,A.a1(t,A.an(D.qb,B.w,t,t,r*0.2),B.j,t,t,new A.X(B.l,t,v,t,t,t,B.av),t,w,t,t,t,t,t,w),t,t,t,0,t,t))
return A.bh(t,!0,t,A.ce(t,A.br(new A.dy(B.bi,t,B.bt,B.j,o,t),p,p),B.L,!1,D.aso,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,q,t,t,t,t,t,t,!1,B.aa),!1,t,t,t,!1,t,!1,t,t,t,t,t,t,t,t,t,t,"Profile photo. Tap to change it.",t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,B.M,t)}}
C.acp.prototype={
t(d){var w=new C.b6v(d),v=this.c,u=A.a([D.acF,w.$3("choose",D.wN,v?"Choose a new photo":"Add a photo")],x.u)
if(v)u.push(w.$4$color("remove",B.i_,"Remove photo",B.G))
return A.W(u,B.p,null,B.e,B.X,0,B.k)}}
var z=a.updateTypes(["ap<~>()"])
C.aIX.prototype={
$0(){var w=0,v=A.q(x.v),u,t=this,s
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:s=t.a
w=3
return A.h(A.ze(s),$async$$0)
case 3:if(!e||s.e==null){w=1
break}w=4
return A.h(A.af(s,!1,x.e).nr(),$async$$0)
case 4:if(s.e==null){w=1
break}A.ak7(s)
A.bF(s).cj(0,"/",null)
case 1:return A.o(u,v)}})
return A.p($async$$0,v)},
$S:2}
C.aWg.prototype={
$0(){return this.a.d=!0},
$S:0}
C.aWh.prototype={
$0(){return this.a.d=!1},
$S:0}
C.b6v.prototype={
$4$color(d,e,f,g){var w,v=null,u=g==null
if(u)w=A.c(this.a).ax.a===B.b?B.t:B.r
else w=g
w=A.an(e,w,v,v,v)
if(u)u=A.c(this.a).ax.a===B.b?B.t:B.r
else u=g
return A.iu(!1,B.W,v,v,!0,v,v,v,!0,v,new A.w("avatar-"+d,x.q),w,v,v,v,v,new C.b6w(this.a,d),!1,v,v,v,v,v,v,v,A.j(f,v,v,v,v,A.t(v,v,u,v,v,v,v,v,v,v,v,v,v,v,B.a3,v,v,!0,v,v,v,v,v,v,v,v),v,v,v,v),v,v,v)},
$3(d,e,f){return this.$4$color(d,e,f,null)},
$S:831}
C.b6w.prototype={
$0(){return A.aZ(this.a,!1).aV(this.b)},
$S:0};(function installTearOffs(){var w=a._instance_0u
w(C.Q4.prototype,"gaqh","mP",0)})();(function inheritance(){var w=a.inheritMany,v=a.inherit
w(A.a3,[C.zm,C.a4n,C.acp])
w(A.ne,[C.aIX,C.aWg,C.aWh,C.b6w])
v(C.Aq,A.N)
v(C.Q4,A.O)
v(C.b6v,A.ip)})()
A.z4(b.typeUniverse,JSON.parse('{"zm":{"a3":[],"d":[],"e":[]},"a4n":{"a3":[],"d":[],"e":[]},"Aq":{"N":[],"d":[],"e":[]},"Q4":{"O":["Aq"]},"acp":{"a3":[],"d":[],"e":[]}}'))
var y={b:"https://findfooddelivery-backend.onrender.com/auth/me/avatar"}
var x={e:A.aH("l5"),u:A.aH("D<d>"),y:A.aH("aB<r,@>"),w:A.aH("r"),q:A.aH("w<r>"),v:A.aH("~")};(function constants(){D.OG=new A.fg(2.4,null,null,null,null,B.y,null,null,null,null)
D.U0=new C.Aq(60,null)
D.pT=new A.a5(60979,"MaterialIcons",null,!1)
D.wN=new A.a5(62109,"MaterialIcons",null,!1)
D.qb=new A.a5(983181,"MaterialIcons",null,!1)
D.qi=new A.aJ(B.lW,null,null,null,null)
D.acF=new A.e5("Profile photo","Optional. It helps restaurants and riders recognise you.",null)
D.ru=new C.a4n(null)
D.Jx=new A.x(!0,B.G,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aso=new A.w("edit-avatar",x.q)})()};
(a=>{a["ax4jbK9lw8TZXA+NoQell0G0HBg="]=a.current})($__dart_deferred_initializers__);