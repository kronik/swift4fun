#!/usr/bin/env python2.7

# This script walks the asset catalogs in your project and spits out one .h/.m pair with
# classes and methods for UIImages found therein.

# The script tries to make valid and sensible identifiers out of your image names.
# If it can't do so for your use case, please submit a bug at 
# https://github.com/crushlovely/Amaro/issues.

# Inspired by https://github.com/square/objc-codegenutils,
# and using some slugification code from http://flask.pocoo.org/snippets/5/.

from __future__ import print_function, unicode_literals
import AmaroLib as lib
from glob import glob
import os.path

def imageNamesInCatalog(catalogDir):
    imagesetDirs = glob(os.path.join(catalogDir, '*.imageset'))
    return [lib.bareFilename(d) for d in imagesetDirs]

def classNameForCatalog(catalogDir, classPrefix):
    name = lib.bareFilename(catalogDir)
    return classPrefix + lib.variableNameForString(name, [classPrefix], ['AssetCatalog', 'Catalog'], lower = False) + 'Catalog'

def headerAndImpContentsForCatalog(catalogDir, classPrefix):
    imageNames = imageNamesInCatalog(catalogDir)
    if not imageNames:
        return ([], [])

    className = classNameForCatalog(catalogDir, classPrefix)

    hLines = ['@interface {}: NSObject\n'.format(className)]
    mLines = ['@implementation {}\n'.format(className)]

    for imageName in imageNames:
        identifier = lib.variableNameForString(imageName)
        hLines.append('+(UIImage *)' + identifier + ';')
        mLines.append('+(UIImage *)' + identifier + ' { return [UIImage imageNamed:@"' + imageName + '"]; }')

    hLines.append('\n@end')
    mLines.append('\n@end')

    return ('\n'.join(hLines), '\n'.join(mLines))


def assembleAndOutput(lines, outputDir, outputBasename):
    warning = '// This file is automatically generated at build time from your asset catalogs.\n'
    warning += '// Any edits you make will be overwritten.\n\n'

    header = warning
    header += '#import <Foundation/Foundation.h>\n\n'
    header += '\n\n'.join(lines[0])

    imp = warning
    imp += '#import "' + outputBasename + '.h"\n\n'
    imp += '\n\n'.join(lines[1])

    headerFn = os.path.join(outputDir, outputBasename + '.h')
    impFn = os.path.join(outputDir, outputBasename + '.m')

    with open(headerFn, 'w') as f:
        f.write(header.encode('utf-8'))

    with open(impFn, 'w') as f:
        f.write(imp.encode('utf-8'))

if __name__ == '__main__':
    outBasename = 'AssetCatalogIdentifiers'
    prefix = lib.classPrefix

    projectDir = os.path.join(lib.getEnv('SRCROOT'), lib.getEnv('PROJECT_NAME'))

    catalogDirs = list(lib.recursiveGlob(projectDir, '*.xcassets', includeDirs = True))
    lines = ([], [])
    for catalogDir in catalogDirs:
        hString, mString = headerAndImpContentsForCatalog(catalogDir, prefix)
        if hString:
            lines[0].append(hString)
            lines[1].append(mString)

    outDir = os.path.join(projectDir, 'Other-Sources', 'Generated')
    assembleAndOutput(lines, outDir, outBasename)

    print('Generated {}.h and .m for image assets in the following catalog(s): {}'.format(outBasename, ', '.join([os.path.basename(d) for d in catalogDirs])))
