import 'dart:html' as html;
import "dart:math" as math;
import 'package:stagexl/stagexl.dart';
import "package:vector_math/vector_math.dart";

html.DivElement infoDiv = html.querySelector("#info");
Stage stage = new Stage(html.querySelector('#stage'));
RenderLoop renderLoop = new RenderLoop();
ResourceManager resourceManager = new ResourceManager();
BitmapFilter hoverFilter = new ColorMatrixFilter([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
        [255, 0, 0, 0]);
List<Slice> slices = []
..add(new Slice("pieElement0", "assets/pieElement0.jpg", new Vector2(20.0,60.0)))
..add(new Slice("pieElement1", "assets/pieElement1.jpg", new Vector2(0.0,40.0)))
..add(new Slice("pieElement2", "assets/pieElement2.jpg", new Vector2(-20.0,40.0)))
..add(new Slice("pieElement3", "assets/pieElement3.jpg", new Vector2(-20.0,20.0)))
..add(new Slice("pieElement4", "assets/pieElement4.jpg", new Vector2(20.0,20.0)));


void main() {
  renderLoop.addStage(stage);

  for(Slice slice in slices){
    resourceManager.addBitmapData(slice.assetName, slice.path);    
  }

  resourceManager.load()
    .then((_) => stage.addChild(new PieChart()))
    .catchError((e) => print(e));
    
}

class Slice {
  String assetName;
  String path;
  Vector2 offset;
  
  Slice(this.assetName, this.path, this.offset);
}

class PieChart extends Sprite {
  
  PieChart(){
    Vector2 center = new Vector2(200.0,200.0);
    num radius = 200.0;
    
    var stepSize = 360/slices.length;
    
    for(int i = 0; i < slices.length; i++){
      num startDegree = stepSize * i;
      Slice slice = slices[i];
      var shape = makeSlice(center, radius, startDegree, startDegree + stepSize, slice.assetName, slice.offset);        
      this.addChild(shape);        
    }    
  }
  
  DisplayObject makeSlice(Vector2 center, double radius, num beginDegrees, num endDegrees, String imageName, Vector2 imageOffset){
    
    Sprite slice = new Sprite();
    
    num startingAngle = degreesToRadians(beginDegrees);
    num endingAngle = degreesToRadians(endDegrees);
    
    num centerAngle = degreesToRadians(beginDegrees + (endDegrees - beginDegrees)/2);
    Vector2 imageCenter = center + new Vector2(math.cos(centerAngle), math.sin(centerAngle)) * (radius/2.0);
    
    var bitmapData = resourceManager.getBitmapData(imageName);
    var bitmap = new Bitmap(bitmapData);
    
    double ratio = bitmap.width/bitmap.height;
    
    bitmap.width = radius * ratio;
    bitmap.height = radius / ratio;
    
    Vector2 imageOrigin = imageCenter - new Vector2(bitmap.width, bitmap.height) / 2.0;
    
    bitmap.x = imageOrigin.x + imageOffset.x;
    bitmap.y = imageOrigin.y + imageOffset.y;
    
    var bitmapMask = new Shape();
    renderPath(bitmapMask.graphics, center, radius-1, startingAngle, endingAngle);
    
    var mask = new Mask.shape(bitmapMask);
    
    var bitmapSprite = new Sprite();
    bitmapSprite.addChild(bitmap);
    bitmapSprite.mask = mask;
    slice.addChild(bitmapSprite);
    
    
    renderPath(slice.graphics, center, radius, startingAngle, endingAngle);
    slice.graphics.strokeColor(Color.Red);
    
    //colorFilter.adjustColoration(0xffde458b);
    //colorFilter.
    slice.onMouseOver.listen((MouseEvent me){
      slice.filters = [hoverFilter];
      slice.applyCache(0, 0, radius.toInt()*2, radius.toInt()*2);
    });  
    
    slice.onMouseOut.listen((MouseEvent me){
      slice.filters = [];
      slice.applyCache(0, 0, radius.toInt()*2, radius.toInt()*2);
    });

    return slice;  
  }

}


renderPath(Graphics graphics, Vector2 center, num radius, num startingAngle, num endingAngle){
  graphics.beginPath();
  graphics.moveTo(center.x, center.y);
  graphics.arc(center.x, center.y, radius, 
              startingAngle, endingAngle, false);
  graphics.closePath();
}


num degreesToRadians(degrees) => degrees * math.PI / 180;