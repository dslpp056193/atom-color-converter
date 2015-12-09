ColorConverterView = require './color-converter-view'
{CompositeDisposable} = require 'atom'

module.exports = ColorConverter =
    subscriptions: null

    activate: ->
        @subscriptions = new CompositeDisposable
        @subscriptions.add atom.commands.add 'atom-workspace',
            'color-converter:toggle': => @convert()

    deactivate: ->
        @subscriptions.dispose()

    convert: ->
        if editor = atom.workspace.getActiveTextEditor()
             if selectedText = editor.getSelectedText()
                 patternString = ///(rgba*\s*\()*\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{0,3})\s*((\d{0,3})\s*)*\)*(\;*)///i
                 patternHexString = /// \#[0-9a-fA-F]{6}|\#[0-9a-fA-F]{3} ///i
                 if rgb = selectedText.match patternString
                        editor.delete()
                        editor.insertText(this.rgb2hex(selectedText))
                 else if rgb = selectedText.match patternHexString
                    editor.delete()
                    editor.insertText(this.hex2rgba(selectedText))
    rgb2hex: (rgb) ->
         semis = '';

         if rgb.indexOf(';') != -1
             semis = ';'
         rgb = rgb.replace('rgb', '')
         rgb = rgb.replace('a', '')
         rgb = rgb.replace('(', '')
         rgb = rgb.replace(')', '')
         rgb = rgb.replace(///\s*///g, '')
         rgb = rgb.replace(';', '')

         rgbarr = rgb.split(',')

         color =  "#" + this.componentToHex(rgbarr[0]) + this.componentToHex(rgbarr[1]) + this.componentToHex(rgbarr[2]) + semis

         if color[1] == color[2] &&  color[3] == color[4] &&  color[5] == color[6]
             color = color.substr(0,2) + color[3] + color[5]

         return color

    hex2rgba: (color) ->
        semis = '';

        if color.indexOf(';') != -1
            semis = ';'

        color = color.replace /#/, ''

        if color.length is 3
          color = [
            parseInt(color.slice(0,1) + color.slice(0,1), 16)
            parseInt(color.slice(1,2) + color.slice(1,1), 16)
            parseInt(color.slice(2,3) + color.slice(2,1), 16)
          ]
        else if color.length is 6
          color =[
            parseInt(color.slice(0,2), 16)
            parseInt(color.slice(2,4), 16)
            parseInt(color.slice(4,6), 16)
          ]
        else
          color = [0, 0, 0]

        return semis

    componentToHex: (c) ->
        c = new Number(c)
        hex = c.toString(16)
        if hex.length == 1
            hex = "0" + hex

        return hex
