    diff --git a/Nasal/view.nas b/Nasal/view.nas
    index 41e05e9..14d3159 100644
    --- a/Nasal/view.nas
    +++ b/Nasal/view.nas
    @@ -432,6 +432,11 @@ var pilot_view_limiter = {
           me.xoffsetN = props.globals.getNode("/sim/current-view/x-offset-m");
           me.xoffset_lowpass = aircraft.lowpass.new(0.1);
           me.last_offset = 0;
    +      me.pitchN = props.globals.getNode("/sim/current-view/pitch-offset-deg");
    +      me.yoffsetN = props.globals.getNode("/sim/current-view/y-offset-m");
    +      me.last_yoffset = 0;
    +      me.zoffsetN = props.globals.getNode("/sim/current-view/z-offset-m");
    +      me.last_zoffset = 0;
           me.needs_start = 0;
        },
        start : func {
    @@ -466,6 +471,7 @@ var pilot_view_limiter = {
           me.start();
     
           var hdg = normdeg(me.hdgN.getValue());
    +      var pitch = normdeg(me.pitchN.getValue());
           if (abs(me.last_hdg - hdg) > 180)  # avoid wrap-around skips
              me.hdgN.setDoubleValue(hdg = me.last_hdg);
           elsif (hdg > me.left.heading_max)
    @@ -476,15 +482,24 @@ var pilot_view_limiter = {
     
           # translate view on X axis to look far right or far left
           if (me.enable_xoffset) {
    +         var headRadius = 0.08382;
              var offset = 0;
              if (hdg > me.left.threshold)
                 offset = (me.left.threshold - hdg) * me.left.scale;
              elsif (hdg < me.right.threshold)
                 offset = (me.right.threshold - hdg) * me.right.scale;
     
    -         var new_offset = me.xoffset_lowpass.filter(offset);
    +         var new_offset = me.xoffset_lowpass.filter(offset) - math.sin(hdg * D2R) * math.cos(pitch * D2R) * headRadius;
              me.xoffsetN.setDoubleValue(me.xoffsetN.getValue() - me.last_offset + new_offset);
              me.last_offset = new_offset;
    +
    +         var new_yoffset = math.sin(pitch * D2R) * headRadius;
    +         me.yoffsetN.setDoubleValue(me.yoffsetN.getValue() - me.last_yoffset + new_yoffset);
    +         me.last_yoffset = new_yoffset;
    +
    +         var new_zoffset = abs(math.sin(pitch * D2R)) * abs(math.sin(hdg * D2R)) * headRadius;
    +         me.zoffsetN.setDoubleValue(me.zoffsetN.getValue() - me.last_zoffset + new_zoffset);
    +         me.last_zoffset = new_zoffset;
           }
           return 0;
        },