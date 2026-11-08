// Direct translation of AfterglowCore/RibbonMesh.swift, in the same 17 layers.
export function ribbonMesh({width=1200,height=600,phase=0,energy=0,pulse=0,live=false,reducedMotion=false,bands=[]}={}) {
 const steps=120;
 const amplitude=x=>{if(!bands.length)return 0;const p=Math.max(0,Math.min(1,x))*(bands.length-1),left=Math.floor(p),right=Math.min(bands.length-1,left+1);return bands[left]*(1-p+left)+bands[right]*(p-left);};
 const samples=Array.from({length:steps+1},(_,i)=>{const x=i/steps,local=live?(amplitude(x-.035)+amplitude(x)+amplitude(x+.035))/3:0;return [x,live?Math.min(1,local*.85+energy*.4+pulse*.15):.85,Math.sin(x*Math.PI)*(.05+.055*Math.sin(x*2*Math.PI+phase*.55))];});
 return Array.from({length:17},(_,ribbon)=>samples.map(([x,activity,fan])=>{const layer=ribbon-8,wave=Math.sin(x*3.2*Math.PI-phase+layer*.13)+.38*Math.sin(x*6.4*Math.PI+phase*.8+layer*.09);return {x:x*width,y:reducedMotion?height*.5+Math.sin(x*3*Math.PI+layer*.06)*15+layer*1.5:height*.5+Math.tanh((wave*1.05+fan*layer)*activity)*height*.46};}));
}
export function ribbonPoint(points,t){const offset=Math.max(0,Math.min(1,t))*(points.length-1),left=Math.floor(offset),right=Math.min(points.length-1,left+1),f=offset-left;return {x:points[left].x+(points[right].x-points[left].x)*f,y:points[left].y+(points[right].y-points[left].y)*f};}
