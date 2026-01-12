#include <QApplication>
#include <QDebug>

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    qDebug() << "Hello, World from Qt GUI!";
    qDebug() << "Qt version:" << QT_VERSION_STR;
    
    return app.exec();
}
