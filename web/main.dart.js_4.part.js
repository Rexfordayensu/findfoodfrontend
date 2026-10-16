((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,C={yL:function yL(d,e){this.c=d
this.a=e},a2R:function a2R(d){this.a=d},aFR:function aFR(d){this.a=d},zP:function zP(d,e){this.c=d
this.a=e},OY:function OY(){this.d=!1
this.c=this.a=null},aSH:function aSH(d){this.a=d},aSI:function aSI(d){this.a=d},aaD:function aaD(d,e){this.c=d
this.a=e},b29:function b29(d){this.a=d},b2a:function b2a(d,e){this.a=d
this.b=e},
Z1(d,e,f,g){var w=null
return new A.Hv(!0,g,w,w,w,w,B.j,w,!1,w,!0,w,new C.a7R(f,d,w,w,w),e)},
a7R:function a7R(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
Wz(d,e,f){var w=0,v=A.q(x.y),u,t,s,r
var $async$Wz=A.m(function(g,h){if(g===1)return A.n(h,v)
for(;;)switch(w){case 0:s=A.Je("POST",A.as(y.b,0,null))
s.r.p(0,"Authorization","Bearer "+f)
s.y.push(A.Jd("file",e,A.FF(d),d))
r=A
w=4
return A.j($.aH().er(0,s),$async$Wz)
case 4:w=3
return A.j(r.pt(h),$async$Wz)
case 3:t=h
if(t.b===200){u=A.bi(t)
w=1
break}throw A.h(A.ag(A.br(t,"Could not upload your photo")))
case 1:return A.o(u,v)}})
return A.p($async$Wz,v)},
ajw(d){var w=0,v=A.q(x.y),u,t,s
var $async$ajw=A.m(function(e,f){if(e===1)return A.n(f,v)
for(;;)switch(w){case 0:t=x.w
w=3
return A.j($.aH().t4(0,A.as(y.b,0,null),A.Q(["Authorization","Bearer "+d],t,t)),$async$ajw)
case 3:s=f
if(s.b===200){u=A.bi(s)
w=1
break}throw A.h(A.ag(A.br(s,"Could not remove your photo")))
case 1:return A.o(u,v)}})
return A.p($async$ajw,v)}},D
J=c[1]
A=c[0]
B=c[2]
C=a.updateHolder(c[9],C)
D=c[13]
C.yL.prototype={
t(d){var w,v,u=null,t=A.af(d,!0,x.e),s=t.f,r=s==null?u:B.d.a2(s).length!==0
if(r===!0){s.toString
w=s}else w="Your account"
s=x.u
r=A.a([A.i(w,B.JG,u,u,u,A.t(u,u,A.c(d).ax.a===B.c?B.v:B.u,u,u,u,u,u,u,u,u,18,u,u,B.C,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u)],s)
v=t.r
if(v!=null&&v.length!==0)r.push(A.i(v,B.JE,u,u,u,A.t(u,u,A.c(d).ax.a===B.c?B.t:B.r,u,u,u,u,u,u,u,u,13,u,u,u,u,u,!0,u,u,u,u,u,u,u,u),u,u,u,u))
r.push(new A.Z(B.oD,A.i(this.c,u,u,u,u,B.ry,u,u,u,u),u))
return A.W(A.a([D.SX,B.e1,A.ae(A.U(r,B.q,u,B.e,B.f,0,B.k),1)],s),B.i,u,B.e,B.f,0,u)}}
C.a2R.prototype={
t(d){return new A.Ab("Sign out",new C.aFR(d),B.JA)}}
C.zP.prototype={
L(){return new C.OY()}}
C.OY.prototype={
mD(){var w=0,v=A.q(x.v),u,t=2,s=[],r=[],q=this,p,o,n,m,l,k,j,i,h,g
var $async$mD=A.m(function(d,e){if(d===1){s.push(e)
w=t}for(;;)switch(w){case 0:h=q.c
h.toString
p=A.af(h,!1,x.e)
h=p.w
if(h==null)h=""
j=q.c
j.toString
w=3
return A.j(A.e4(j,new C.aaD(h.length!==0,null),x.w),$async$mD)
case 3:o=e
if(o==null||q.c==null){w=1
break}q.n(new C.aSH(q))
t=5
w=o==="remove"?8:9
break
case 8:h=p.c
h.toString
w=10
return A.j(C.ajw(h),$async$mD)
case 10:n=e
h=J.C(n,"avatar_url")
h=h==null?null:J.bJ(h)
w=11
return A.j(p.uJ(h),$async$mD)
case 11:h=q.c
if(h!=null)A.b5(h,"Photo removed.",!1)
r=[1]
w=6
break
case 9:w=12
return A.j(new A.oQ().u8(85,800,800,B.hP),$async$mD)
case 12:m=e
if(m==null){r=[1]
w=6
break}h=p.c
h.toString
w=13
return A.j(m.oL(),$async$mD)
case 13:j=e
w=14
return A.j(C.Wz(m.b,j,h),$async$mD)
case 14:l=e
h=J.C(l,"avatar_url")
h=h==null?null:J.bJ(h)
w=15
return A.j(p.uJ(h),$async$mD)
case 15:h=q.c
if(h!=null)A.b5(h,"Looking good! Photo updated.",!1)
r.push(7)
w=6
break
case 5:t=4
g=s.pop()
k=A.a5(g)
h=q.c
if(h!=null)A.b5(h,A.b8(k),!0)
r.push(7)
w=6
break
case 4:r=[2]
case 6:t=2
if(q.c!=null)q.n(new C.aSI(q))
w=r.pop()
break
case 7:case 1:return A.o(u,v)
case 2:return A.n(s.at(-1),v)}})
return A.p($async$mD,v)},
t(d){var w,v,u=this,t=null,s=A.af(d,!0,x.e),r=u.a.c,q=u.d?t:u.gaoc(),p=r+4,o=A.a([new A.CP(s.f,s.w,r,t)],x.u)
if(u.d){w=r*0.36
o.push(A.K0(4,A.bmq(A.zu(A.c7(A.bv(D.NJ,w,w),t,t),B.o6,!0)),4))}w=r*0.38
v=A.b_(A.c(d).ax.a===B.c?B.cl:B.y,B.n,2)
o.push(A.h1(0,A.a3(t,A.ao(D.pJ,B.x,t,t,r*0.2),B.j,t,t,new A.X(B.m,t,v,t,t,t,B.ax),t,w,t,t,t,t,t,w),t,t,t,0,t,t))
return A.bh(t,!0,t,A.cf(t,A.bv(new A.du(B.bg,t,B.bq,B.j,o,t),p,p),B.K,!1,D.aph,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,q,t,t,t,t,t,t,!1,B.aa),!1,t,t,t,!1,t,!1,t,t,t,t,t,t,t,t,t,t,"Profile photo. Tap to change it.",t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,t,B.M,t)}}
C.aaD.prototype={
t(d){var w=new C.b29(d),v=this.c,u=A.a([D.aau,w.$3("choose",D.wa,v?"Choose a new photo":"Add a photo")],x.u)
if(v)u.push(w.$4$color("remove",B.je,"Remove photo",B.G))
return A.U(u,B.q,null,B.e,B.Z,0,B.k)}}
C.a7R.prototype={
t(d){var w,v=null,u=A.by(d,B.aM)
u=u==null?v:u.gbN()
u=A.I((u==null?B.aq:u).aI(0,14)/14,1,2)
A.bnn(d)
u=A.ar(8,4,u-1)
u.toString
w=A.a([this.d,new A.eH(1,B.bG,this.c,v)],x.u)
return A.W(w,B.i,v,B.e,B.Z,u,v)}}
var z=a.updateTypes(["az<~>()"])
C.aFR.prototype={
$0(){var w=0,v=A.q(x.v),u,t=this,s
var $async$$0=A.m(function(d,e){if(d===1)return A.n(e,v)
for(;;)switch(w){case 0:s=t.a
w=3
return A.j(A.yC(s),$async$$0)
case 3:if(!e||s.e==null){w=1
break}w=4
return A.j(A.af(s,!1,x.e).nc(),$async$$0)
case 4:if(s.e==null){w=1
break}A.ai9(s)
A.bM(s).cl(0,"/",null)
case 1:return A.o(u,v)}})
return A.p($async$$0,v)},
$S:2}
C.aSH.prototype={
$0(){return this.a.d=!0},
$S:0}
C.aSI.prototype={
$0(){return this.a.d=!1},
$S:0}
C.b29.prototype={
$4$color(d,e,f,g){var w,v=null,u=g==null
if(u)w=A.c(this.a).ax.a===B.c?B.v:B.u
else w=g
w=A.ao(e,w,v,v,v)
if(u)u=A.c(this.a).ax.a===B.c?B.v:B.u
else u=g
return A.jB(!1,B.Y,v,v,!0,v,v,v,!0,v,new A.y("avatar-"+d,x.q),w,v,v,v,v,new C.b2a(this.a,d),!1,v,v,v,v,v,v,v,A.i(f,v,v,v,v,A.t(v,v,u,v,v,v,v,v,v,v,v,v,v,v,B.a2,v,v,!0,v,v,v,v,v,v,v,v),v,v,v,v),v,v,v)},
$3(d,e,f){return this.$4$color(d,e,f,null)},
$S:811}
C.b2a.prototype={
$0(){return A.aZ(this.a,!1).aX(this.b)},
$S:0};(function installTearOffs(){var w=a._instance_0u
w(C.OY.prototype,"gaoc","mD",0)})();(function inheritance(){var w=a.inheritMany,v=a.inherit
w(A.a6,[C.yL,C.a2R,C.aaD,C.a7R])
w(A.oq,[C.aFR,C.aSH,C.aSI,C.b2a])
v(C.zP,A.L)
v(C.OY,A.N)
v(C.b29,A.iE)})()
A.EB(b.typeUniverse,JSON.parse('{"yL":{"a6":[],"d":[],"e":[]},"a2R":{"a6":[],"d":[],"e":[]},"zP":{"L":[],"d":[],"e":[]},"OY":{"N":["zP"]},"aaD":{"a6":[],"d":[],"e":[]},"a7R":{"a6":[],"d":[],"e":[]}}'))
var y={b:"https://findfooddelivery-backend.onrender.com/auth/me/avatar"}
var x={e:A.aJ("kJ"),u:A.aJ("J<d>"),y:A.aJ("aF<r,@>"),w:A.aJ("r"),q:A.aJ("y<r>"),v:A.aJ("~")};(function constants(){D.NJ=new A.fp(2.4,null,null,null,null,B.y,null,null,null,null)
D.j0=new A.a1(0,0,0,4)
D.SX=new C.zP(60,null)
D.py=new A.a4(60979,"MaterialIcons",null,!1)
D.wa=new A.a4(62109,"MaterialIcons",null,!1)
D.pJ=new A.a4(983181,"MaterialIcons",null,!1)
D.pR=new A.aW(B.lJ,null,null,null,null)
D.aau=new A.eh("Profile photo","Optional. It helps restaurants and riders recognise you.",null)
D.r_=new C.a2R(null)
D.IP=new A.x(!0,B.G,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aph=new A.y("edit-avatar",x.q)})()};
(a=>{a["FXLl+qaiai4v8hhGU+wSYA8laDU="]=a.current})($__dart_deferred_initializers__);