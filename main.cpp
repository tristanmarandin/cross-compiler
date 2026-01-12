#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    
    qDebug() << "Hello, World from Qt Core!";
    qDebug() << "Qt Core version:" << QT_VERSION_STR;
    
    return app.exec();
}
