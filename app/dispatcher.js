var guid = require('guid');

var listeners = {};

//register will be passed a callback, as a function argument called cb
//then cb will be passed ot the listerns obejct as id
module.exports = {
    register: function (cb) {
        var id = guid.raw();
        listeners[id] = cb;
        return id;
    },
    //console info serves for debug info
    dispatch: function (payload) {
        console.info("Dispatching...", payload);
        for(var id in listeners){
            var listener = listeners[id];
            listener(payload);
        }
    }
}