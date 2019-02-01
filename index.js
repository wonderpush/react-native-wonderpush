
import { NativeModules } from 'react-native';

const { RNWonderpush } = NativeModules;

const hocAsync = function(/* functionToCall, args, callback */) {
  const args = [...arguments]
  const functionToCall = args.splice(0, 1)[0]
  const callback = args.splice(-1, 1)[0]

  if(callback) return functionToCall(...args, callback)
  return new Promise( function(resolve, reject){
    functionToCall(...args, function(err, res){
      if(err) return reject(err)
      resolve(res)
    })
  })
}

const wonderpush = {
  getAccessToken: function(cb = null){
    return hocAsync(RNWonderpush.getAccessToken, cb)
  },
  getDelegate: function(cb = null){
    return hocAsync(RNWonderpush.getDelegate, cb)
  },
  getDeviceId: function(cb = null){
    return hocAsync(RNWonderpush.getDeviceId, cb)
  },
  getInstallationCustomProperties: function(cb = null){
    return hocAsync(RNWonderpush.getInstallationCustomProperties, cb)
  },
  getInstallationId: function(cb = null){
    return hocAsync(RNWonderpush.getInstallationId, cb)
  },
  getNotificationEnabled: function(cb = null){
    return hocAsync(RNWonderpush.getNotificationEnabled, cb)
  },
  getPushToken: function(cb = null){
    return hocAsync(RNWonderpush.getPushToken, cb)
  },
  getUserId: function(cb = null){
    return hocAsync(RNWonderpush.getUserId, cb)
  },
  isReady: function(cb = null){
    return hocAsync(RNWonderpush.isReady, cb)
  }
}

export default Object.assign({}, RNWonderpush, wonderpush);
