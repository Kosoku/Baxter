#!/bin/sh

mogenerator -m $SRCROOT/$TARGET_NAME/Model.xcdatamodeld/Model.xcdatamodel -H $SRCROOT/$TARGET_NAME/CoreData -M $SRCROOT/$TARGET_NAME/CoreData/machine --template-var arc=true
