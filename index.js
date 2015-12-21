'use strict';

import React, { requireNativeComponent, PropTypes, NativeModules, View } from 'react-native';

const Image2DContextModule = NativeModules.Image2DContextModule;

export class Image2DContext {
    static async create(options) {
        let id = await Image2DContextModule.create(options);
        return new Image2DContext(id);
    }

    constructor(id) {
        this.contextId = id;
    }

    async save(options) {
        return Image2DContextModule.save({
            id: this.contextId,
            params: options
        });
    }

    async getAsBase64String() {
        return Image2DContextModule.getAsBase64String({
            id: this.contextId
        });
    }

    async getSize() {
        let size = {};

        size.width = await Image2DContextModule.getWidth({
            id: this.contextId
        });

        size.height = await Image2DContextModule.getHeight({
            id: this.contextId
        });

        return size;
    }

    async crop(options) {
        return Image2DContextModule.crop({
            id: this.contextId,
            params: options
        });
    }

    async drawBorder(options) {
        if (!options.color) {
            options.color = 'black';
        }

        return Image2DContextModule.drawBorder({
            id: this.contextId,
            params: options
        });
    }

    async release() {
        return Image2DContextModule.release({
            id: this.contextId
        });
    }
}
