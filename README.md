# ClassifierVOC_for_ClassifulNet
This MATLAB program can devide sample images into servel classes according `groundtruth` message in XML file

---
## PREPARED
VOC2007 dataset is need:
> VOC2007
   
> > Annotations
> > > name.xml

> > JPEGImages
> > > name.jpg

> > labels
> > > name.txt

`name.txt` can be genarated by code in [darnet/scripts/voc_label.py](https://github.com/pjreddie/darknet) contains:

```
class_ind(start with 0) xmin xmax ymin ymax
```


---
## START
#### 1. run the lateast main*.m, for example
```
run main9.m
```
- Then the result images will be ploted in `output1` file which will be named as ：

```
classes - subclasses - amounts of images.jpg 
```
- And the result txt will be saved in `output4` file which will be named as :

```
classes - subclasses.txt
```
- This txt can be edited according to the result images and the code can read these to cover the old result.

---
#### 2. run the printresult.m
- Then the bounding box can be genarated according to the lateast classes result, which will be drawn in `output2` file and named as :

```
new classes - 12.jpg
```
- `annotation_bbx.txt` and `classifier.txt` will also be genarated.
  - `annotatioin_bbx.txt` :
    ```
    class_index(start with 1) tag_index(start with 1) xmin ymin xmax ymax
    ```
  - `annotatioin_bbx.txt` :
    ```
    imagename class_index change_index
    
    ```
    `change_index` above is the method to deal with the images:
    
        change_index | deal_method
        ---|---
        1 | Original
        2 | Flip Horizontal
        3 | Flip vertical
        4 | Flip Diagonal
---
#### 3. The bounding box can be optimizer again with lateast `again_optimizer*.m`

```
run again_optimizer2.m
```
- The new class result can be genarated in `output3` file and named as ：

```
again-new class.jpg
```






