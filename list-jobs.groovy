// Вывод всех заданий (Jobs) в Jenkins, включая те, что находятся в папках (Folders от Clooudbees):
import jenkins.model.*
import hudson.model.*
def inst = Jenkins.getInstance()
Jenkins.instance.getAllItems(AbstractItem.class).each {
    println it.fullName
};
