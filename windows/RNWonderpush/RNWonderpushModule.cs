using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Wonderpush.RNWonderpush
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNWonderpushModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNWonderpushModule"/>.
        /// </summary>
        internal RNWonderpushModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNWonderpush";
            }
        }
    }
}
