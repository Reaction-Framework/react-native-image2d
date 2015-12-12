'use strict';

import React, { requireNativeComponent, PropTypes, NativeModules, View } from 'react-native';

const DrawingContextModule = NativeModules.DrawingContextModule;

export class DrawingContext {
    static async create(options) {
        let id = await DrawingContextModule.create(options);
        return new DrawingContext(id);
    }

    constructor(id) {
        this.contextId = id;
    }

    async save(options) {
        return DrawingContextModule.save({
            id: this.contextId,
            params: options
        });
    }

    async getAsBase64String() {
        return DrawingContextModule.getAsBase64String({
            id: this.contextId
        });
    }

    async getSize() {
        let size = {};

        size.width = await DrawingContextModule.getWidth({
            id: this.contextId
        });

        size.height = await DrawingContextModule.getHeight({
            id: this.contextId
        });

        return size;
    }

    async crop(options) {
        return DrawingContextModule.crop({
            id: this.contextId,
            params: options
        });
    }

    async drawBorder(options) {
        return DrawingContextModule.drawBorder({
            id: this.contextId,
            params: options
        });
    }

    async release() {
        return DrawingContextModule.release({
            id: this.contextId
        });
    }
}
